#!/bin/bash
#
# Cree par Eric le 25/07/2023
#
# Maj le 26/07/2023
#
# Usage : createNewHost.sh hostName nbInterfaces gateway ip1 mask1 parent1 [ip2 mask2 parent2...]
#

hostName=$1
nbInterfaces=$2
gateway=$3

# Si le nombre d'arguments n'est pas suffisant
if [ $# -lt 3 ]
then
   echo "Il manque des arguments, la syntaxe de la commande est : 
createNewHost.sh hostName nbInterfaces gateway ip1 mask1 parent1 [ip2 mask2 parent2...]" 
   exit 1
fi

# Si le nombre d'arguments est trop grand
if [ $# -gt 9 ]
then
   echo "Il y a trop d'arguments, il peut y en avoir 9 au maximum :
createNewHost.sh hostName nbInterfaces gateway ip1 mask1 parent1 [ip2 mask2 parent2...]" 
   exit 1
fi

# Si le hostName n'est pas une chaine
if [ ! -n $hostName ]
then
   echo "Le premier argument doit etre le nom de la machine :
createNewHost.sh hostName nbInterfaces gateway ip1 mask1 parent1 [ip2 mask2 parent2...]" 
   exit 1
fi

# Si le nombre d'interfaces n'est pas un nombre
# re='^[0-9]+$'
# if ! [[ $nbInterfaces =~ $re ]]
# then
#    echo "Le second argument doit etre un chiffre :
# createNewHost.sh hostName nbInterfaces gateway ip1 mask1 [ip2 mask2 ...]" 
#    exit 1
# fi

# Si la gateway n'est pas une adresse IP
ipAddressformat='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
if ! [[ $gateway =~ $ipAddressformat ]]
then
   echo "Le troisieme argument doit etre une adresse IP :
createNewHost.sh hostName nbInterfaces gateway ip1 mask1 parent1 [ip2 mask2 parent2...]" 
   exit 1
fi

#
# ... ajouter les conditions ou pas...
#

# On cree le conteneur
lxc init debianBase3 $hostName --storage pool1
lxc start $hostName

# On cree les fichiers de configuration reseau
for i in $(seq 1 $nbInterfaces)
do
    indiceIP=$(( ( 3 * $i ) + 1 ))
    indiceMask=$(( $indiceIP + 1 ))
    parent=$(( $indiceIP + 2 ))
    echo "[Match]
Name=eth$(( $i - 1))

[Network]
Address=${!indiceIP}/${!indiceMask}" > baseScripts/${hostName}-eth$(( $i - 1 )).network
    if [ $i -eq 1 ]
    then 
        echo "Gateway=$gateway" >> baseScripts/${hostName}-eth$(( $i - 1 )).network
    fi
    echo "DNS=8.8.8.8" >> baseScripts/${hostName}-eth$(( $i - 1 )).network
    lxc file push baseScripts/${hostName}-eth$(( $i - 1 )).network $hostName/etc/systemd/network/eth$(( $i - 1 )).network
    lxc config device add $hostName eth$(( $i - 1 )) nic name=eth$(( $i - 1 )) nictype=bridged parent=lxdbr${!parent}
done

sleep 2
# On modifie la configuration reseau
lxc exec $hostName -- /usr/bin/systemctl enable systemd-networkd
sleep 2
lxc exec $hostName -- /usr/bin/systemctl restart systemd-networkd
sleep 2
# lxc exec $hostName -- mkdir /root/.ssh

# On efface les fichiers de configuration
rm baseScripts/${hostName}-eth*.network

# On execute les commandes associees
# command=

# On positionne la clef SSH du serveur sur le conteneur
lxc file push /root/.ssh/id_rsa_ansible.pub $hostName/root/.ssh/authorized_keys
ssh-keygen -f "/root/.ssh/known_hosts" -R "$ip1"
ssh -o "StrictHostKeyChecking no" root@$ip1 -i /root/.ssh/id_rsa_ansible "cat /root/.ssh/authorized_keys"
