#!/bin/bash
#############################################################################
# A script for splitting the test suite across nodes on CircleCI.
#############################################################################

DEBUG='echo'

acceptance_tests () {
  status=0
  BEAKER_set=''

  if [ "$CIRCLE_NODE_INDEX" != 3 ]; then
    echo "Not to be built on this node ($CIRCLE_NODE_INDEX)."
  else
    # If we reach this point, we're on the right node. Check if we're on
    # a release branch.
    echo "$CIRCLE_BRANCH" | grep -Eq '^release/'

    if [ $? != 0 ]; then
      echo "Not a release branch."
    else
      BEAKER_set="$1"
    fi
  fi

  if [ ! -z "$BEAKER_set" ]; then
    BEAKER_destroy=no BEAKER_set=$BEAKER_set bundle exec rake beaker
    status=$?
    docker ps -a | grep -v 'CONTAINER ID' | xargs docker rm -f
  fi

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
    $DEBUG rake module:tag
  fi

  git ls-remote --tags 2> /dev/null | grep -q "refs/tags/${local_version}"

  if [ $? != 0 ]; then
    echo "Pushing remote tag $local_version."
    $DEBUG git push --tags
  fi

  forge_version=$( ./scripts/module_version.py --forge )

  if [ -z "$forge_version" ]; then
    echo "Unable to find forge module version."
    exit 1
  fi

  echo "Module version (forge): $forge_version"

  if [ $local_version != $forge_version ]; then
    echo "Build and deploy version $local_version."
    $DEBUG rake module:clean
    $DEBUG rake build
    echo "Populating $HOME/.puppetforge.yml"
    $DEBUG module:push
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

unit_tests () {
  status=0
  bundle --version
  gem --version
  ruby --version
  rvm --version
  bundle exec rake lint || status=$?
  bundle exec rake validate || status=$?

  bundle exec rake spec SPEC_OPTS="--format RspecJunitFormatter \
      -o $CIRCLE_TEST_REPORTS/rspec/puppet.xml" || status=$?
  return $status
}


if [ ! -z "$RVM" ]; then
  echo "Using rvm version $RVM"
  # Set the path
  export PATH=/home/ubuntu/.rvm/gems/ruby-${RVM}/bin:$PATH
  # Load RVM into a shell session *as a function*
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  rvm use ruby-${RVM}
fi

subcommand=$1 
shift
$subcommand $*
exit $?
