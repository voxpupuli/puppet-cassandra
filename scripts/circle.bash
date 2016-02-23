#!/bin/bash
#############################################################################
# A script for splitting the test suite across nodes on CircleCI.
#############################################################################

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH=/home/ubuntu/.rvm/gems/ruby-1.9.3-p448/bin:$PATH

acceptance_tests () {
  i=0
  nodes=()

  for node in $( rake beaker_nodes | grep '^circle' ) ; do
    if [ $(($i % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX ]; then
      nodes+=" $node"
    fi

    ((i=i+1))
  done

  echo "Nodes: $nodes"
}

merge () {
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

  if [ ! -z "$RVM" ]; then
    rvm use $RVM --install --fuzzy
    export BUNDLE_GEMFILE=$PWD/Gemfile
    rm -f Gemfile.lock
    ruby --version
    rvm --version
  fi

  bundle --version
  gem --version
  bundle install --without development
  bundle exec rake lint || status=$?

  if [ ! -z "$RUBOCOP" ]; then
    $RUBOCOP || status=$?
  fi

  bundle exec rake validate || status=$?

  bundle exec rake spec SPEC_OPTS="--format RspecJunitFormatter \
      -o $CIRCLE_TEST_REPORTS/rspec/puppet.xml" || status=$?
  return $status
}

export RVM=''
export RUBOCOP=''

case $CIRCLE_NODE_INDEX in
  0)  export RVM=1.9.3
      export PUPPET_GEM_VERSION="~> 3.0"
      ;;
  1)  export RVM=2.1.5
      export PUPPET_GEM_VERSION="~> 3.0"
      ;;
  2)  export RVM=2.1.6
      export PUPPET_GEM_VERSION="~> 4.0"
      export STRICT_VARIABLES="yes"
      export RUBOCOP='bundle exec rake rubocop'
      ;;
  3)  export RUBOCOP='bundle exec rake rubocop'
      ;;
esac

subcommand=$1 
shift
$subcommand $*
exit $?
