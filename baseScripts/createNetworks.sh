#!/bin/bash
#
# Cree par Eric le 25/07/2023
#
# Maj le 26/07/2023
#
# Usage : createNetworks.sh nbNetworks [net1/mask [192.168.0.0/24 ...]]"
#

# Si le nombre d'arguments n'est pas suffisant
if [ $# -lt 1 ]
then
   echo "Il manque des arguments, la syntaxe de la commande est : 
createNetworks.sh  nbNetworks [net1/mask [192.168.0.0/24 ...]]"
   exit 1
fi

nbNetworks=$1

if [ $nbNetworks -gt 1 ]
then
    nbIterate=$(( $nbNetworks - 1))
    for i in $(seq 1 $nbIterate )
    do
        lxc network create lxdbr${i}
        j=$(( $i + 1 ))
        if [ -z ${!j} ]
        then
            echo "config:
  ipv4.address: 10.0.${i}.1/24
  ipv4.nat: "true"
description: ""
name: lxdbr${i}
type: bridge
used_by:
- /1.0/instances/proxy
managed: true
status: Created
locations:
- none" > ./network_10.0.${i}_profile.yaml
            lxc network edit lxdbr${i} < ./network_10.0.${i}_profile.yaml
            rm ./network_10.0.${i}_profile.yaml
        else
            network=$(echo ${!j} | cut -d "/" -f 1 | cut -d "\"" -f 2)
            networkWithMask=$(echo ${!j} | cut -d "\"" -f 2)
            echo "config:
  ipv4.address: ${networkWithMask}
  ipv4.nat: "true"
description: ""
name: lxdbr${i}
type: bridge
used_by:
- /1.0/instances/proxy
managed: true
status: Created
locations:
- none" > ./network_${network}_profile.yaml
            lxc network edit lxdbr${i} < ./network_${network}_profile.yaml
            rm ./network_${network}_profile.yaml
        fi
    done
fi
