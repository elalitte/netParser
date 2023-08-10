#!/bin/bash
RUNNING_NETWORKS="$(lxc network ls |grep lxd|cut -d " " -f 2)"

for network in $RUNNING_NETWORKS; do
  if [ $network != "lxdbr0" ]
  then
    echo "Destroying $network..."
    lxc network delete $network
  fi
done
