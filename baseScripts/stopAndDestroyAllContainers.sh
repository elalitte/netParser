#!/bin/bash
RUNNING_CONTAINERS="$(lxc list |grep CONTAINER |cut -d " " -f 2 | cut -d " " -f 1)"

for container in $RUNNING_CONTAINERS; do
  echo "Destroying $container..."
  lxc stop $container
  lxc delete $container
done
