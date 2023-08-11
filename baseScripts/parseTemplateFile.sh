#!/bin/bash
#
# Ecrit par Eric le 03/08/23
#
# parseTemplateFile.sh ../templates/templateFile.json

# On remet tout a 0
./baseScripts/resetAll.sh

# On recupere le fichier a parser
fileToParse=$1

# On cree les reseaux
numberOfNetworks=$(cat $fileToParse | jq '.networks.number')
./baseScripts/createNetworks.sh ${numberOfNetworks}

# On cree les machines
# On boucle sur les hotes
numberOfhosts=$(cat $fileToParse | jq '.hosts.number')
for i in $(seq 0 $(( $numberOfhosts - 1 )))
do
    hostName=$(cat $fileToParse | jq ".hosts.hostsList[$i].name" |cut -d "\"" -f 2)
    gateway=$(cat $fileToParse | jq ".hosts.hostsList[$i].gateway" |cut -d "\"" -f 2)
    numberOfInterfaces=$(cat $fileToParse | jq ".hosts.hostsList[$i].interfaces.number")
    allArguments=""
    for j in $(seq 0 $(( $numberOfInterfaces -1 )))
    do
        interfaceArgs=$(cat $fileToParse |
          jq ".hosts.hostsList[$i].interfaces.intDetails[$j].address")
        ipAddress=$(echo $interfaceArgs |
          cut -d "/" -f 1|
          cut -d "\"" -f 2)
        ipMask=$(echo $interfaceArgs |
          cut -d "/" -f 2|
          cut -d "\"" -f 1)
        parent=$(cat $fileToParse |
          jq ".hosts.hostsList[$i].interfaces.intDetails[$j].parent" |
          cut -d "\"" -f 2)
        arguments=" "$ipAddress" "$ipMask" "$parent
        allArguments+=$arguments
    done
    ./baseScripts/createNewHost.sh $hostName $numberOfInterfaces $gateway $allArguments # >/dev/null 2>&1

    # On execute les commandes s'il y en a
    commands=$(cat $fileToParse | 
      jq ".hosts.hostsList[$i].commands" |
      cut -d "[" -f 2 |
      cut -d "]" -f 1)
    readarray -t -d "," commandArray < <(echo $commands)
    for command in "${commandArray[@]}"; do 
        realCommand=$(echo $command |cut -d "\"" -f 2)
        lxc exec $hostName -- bash -c "$realCommand" >/dev/null 2>&1
    done
done
