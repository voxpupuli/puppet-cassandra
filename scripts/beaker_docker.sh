#!/bin/sh
#############################################################################
# A basic utility script for connecting and controlling docker instances
# that have been created by beaker.
#############################################################################

# Define constants
PROG=$( basename $0 )

usage_message () {
  exit_status="$1"
  echo "usage: $PROG connect"
  echo "usage: $PROG destroy"
  exit $exit_status
}

if [ $# -lt 1 ]; then
  usage_message 2
fi

case "$1" in
  connect) port=$( docker ps -n=-1 | grep -v '^CONTAINER' | \
             awk '{ i = NF - 1; print $i }' | sed 's/.*:\(.*\)-.*/\1/' )
           ssh root@localhost -p $port
           ;;
  destroy) docker rm -f $( docker ps -n=-1 -q )
           ;;
  *)       usage_message 2
esac
