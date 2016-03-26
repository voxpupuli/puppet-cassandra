#!/bin/bash
#############################################################################
# A script for splitting the test suite across nodes on CircleCI.
#############################################################################

PUPPET_FORGE_CREDENTIALS_FILE="$HOME/.puppetforge.yml"

acceptance_tests () {
  status=0
  BEAKER_set=''

  echo "$CIRCLE_BRANCH" | grep -Eq '^release/'

  if [ $? != 0 ]; then
    echo "Not a release branch."
    return 0
  fi

  i=0
  nodes=$( rake beaker_nodes | grep '^circle' )
  nodes=$( echo $nodes )

  if [ -z "${nodes}" ]; then
    echo "ERROR: No nodes found."
    exit 1
  fi

  for node in $nodes; do
    if [ $(($i % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX ]; then
      BEAKER_destroy=no BEAKER_set=$node bundle exec rake beaker || status=$?
      docker ps -a | grep -v 'CONTAINER ID' | xargs docker rm -f
    fi
  done

  return $status
}

deploy () {
  local_version=$( ./scripts/module_version.py --local )

  if [ -z "$local_version" ]; then
    echo "Unable to find local module version."
    exit 1
  fi

  echo "Module version (local): $local_version"
  git tag --list | grep --quiet $local_version

  if [ $? != 0 ]; then
    echo "Creating tag $local_version."
    bundle exec rake module:tag || exit $?
  fi

  git ls-remote --tags 2> /dev/null | grep -q "refs/tags/${local_version}"

  if [ $? != 0 ]; then
    echo "Pushing remote tag $local_version."
    git push --tags || exit $?
  fi

  forge_version=$( ./scripts/module_version.py --forge )

  if [ -z "$forge_version" ]; then
    echo "Unable to find forge module version."
    exit 1
  fi

  echo "Module version (forge): $forge_version"

  if [ $local_version != $forge_version ]; then
    echo "Build and deploy version $local_version."
    bundle exec rake module:clean || exit $?
    bundle exec rake build || exit $?

    if [[ -z "$CIRCLE_PROJECT_USERNAME" || -z "$PUPPET_FORGE_PASSWORD" ]]; then
      echo "Not enough data to populate ${PUPPET_FORGE_CREDENTIALS_FILE}"
      exit 1
    else
      echo "Populating $PUPPET_FORGE_CREDENTIALS_FILE"
      echo '---' > $PUPPET_FORGE_CREDENTIALS_FILE
      echo 'url: https://forgeapi.puppetlabs.com' >> $PUPPET_FORGE_CREDENTIALS_FILE
      echo "username: ${CIRCLE_PROJECT_USERNAME}" >> $PUPPET_FORGE_CREDENTIALS_FILE
      echo "password: ${PUPPET_FORGE_PASSWORD}" >> $PUPPET_FORGE_CREDENTIALS_FILE
    fi

    bundle exec rake module:push
  fi
}

merge () {
  if [ ! -z "$RUN_NIGHTLY_BUILD" ]; then
    echo "Skipping merge on nightly build."
    exit 0
  fi

  if [ "$CIRCLE_NODE_INDEX" != 0 ]; then
    echo "Not on the primary Circle node. Skipping merge."
    exit 0
  fi

  target="$1"
  git config --global user.email "circleci@locp.co.uk"
  git config --global user.name  "CircleCI"
  git checkout $target 2> /dev/null

  if [ $? != 0 ]; then
    echo "Attempting to create branch $target."
    git checkout -b "$target" || exit $?
    echo "Branch $target created successfully."
  else
    echo "Branch $target checked out successfully."
  fi

  echo "Fetching from origin with purge."
  git fetch -p origin || exit $?
  git branch -r | grep origin/$target

  if [ $? == 0 ]; then
    echo "Pulling from origin."
    git pull origin $target || exit $?
  else
    echo "$target is not currently on the remote origin."
  fi

  echo "Merging $CIRCLE_BRANCH into $target."
  message="Merge branch $CIRCLE_BRANCH into $target"
  git merge -m "$message" $CIRCLE_BRANCH || exit $?
  echo "Pushing merged branch back to the origin."
  git push --set-upstream origin $target
  return $?
}

subcommand=$1 
shift
$subcommand $*
exit $?
