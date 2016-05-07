#!/bin/bash
#############################################################################
# This script is executed on the remote AWS node to configure a test
# environment and ultimately run the test.
#############################################################################
GITREPO="$1"
GITBRANCH="$2"
NODE_NUMBER="$3"
NODE_TOTAL="$4"

source $HOME/.rvm/scripts/rvm

# Clone the repo and let's do this!
echo "Cloning the $GITBRANCH branch from $GITREPO into workspace."
git clone -b $GITBRANCH $GITREPO workspace
cd workspace
gem install --no-rdoc bundler rake
bundle install --without development
status=0
i=0

for node in $( bundle exec rake beaker_nodes | grep '^aws_' ); do
  if [ $(($i % $NODE_TOTAL)) -eq $NODE_NUMBER ]; then
    BEAKER_set=$node bundle exec rake beaker

    if [ $? != 0 ]; then
      status=1
      echo "$node: FAILED" >> /tmp/beaker-sumary.txt
    else
      echo "$node: OK" >> /tmp/beaker-sumary.txt
    fi
  fi

  ((i=i+1))
done

echo "Node Results Summary"
echo "===================="
cat /tmp/beaker-sumary.txt
exit $status
