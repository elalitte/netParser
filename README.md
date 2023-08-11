# NetParser
## A little json parser to simply create small networks based on lxc/lxd

## Introduction
JSON files are placed in the templates directory.
You can parse them using the parseTemplateFile.sh placed in the baseScripts directory.
But take care, you should send the command from the root directory as links in files
aren't absolute ones.

## Examples
If you want to start the 3nets3hosts.json template, you should use the next command 
and be sure that you are in the root directory.

```sh
# cd netParser
# ./baseScripts/parseTemplateFile.sh templates/3nets3hosts.json
```

Then the networks and hosts should be up in a minute or two depending on the size 
of the network

## JSON files format
The format is quite simple, there is a first part describing the networks,
and another part to describe the hosts/routers (routers are just hosts with
multiple interfaces)

```json
{
  "networks": {
    "number": 3
  },
  "hosts": {
    "number": 3,
    "hostsList": [
      {
        "name": "routeur1",
        "gateway": "10.0.0.1",
        "interfaces": {
          "number": 3,
          "intDetails": [
            {
              "name": "eth0",
              "address": "10.0.0.254/24",
              "parent": "0"
            },
            {
              "name": "eth1",
              "address": "10.0.1.254/24",
              "parent": "1"
            },
            {
              "name": "eth2",
              "address": "10.0.2.254/24",
              "parent": "2"
            }
          ]
        },
        "commands": [
            "echo 1 > /proc/sys/net/ipv4/ip_forward",
            "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
        ]
      },
      {
        "name": "host1",
        "gateway": "10.0.1.254",
        "interfaces": {
          "number": 1,
          "intDetails": [
            {
              "name": "eth0",
              "address": "10.0.1.4/24",
              "parent": "1"
            }
          ]
        },
        "commands": [
            "sleep 1"
        ]
      },
      {
        "name": "host2",
        "gateway": "10.0.2.253",
        "interfaces": {
          "number": 1,
          "intDetails": [
            {
              "name": "eth0",
              "address": "10.0.2.4/24",
              "parent": "2"
            }
          ]
        },
        "commands": [
            "sleep 1"
        ]
      }
    ]
  }
}
```

### Managing Networks
For networks, the first network is lxdbr0 which should be already up and 
running with the address 10.0.0.0/24 (or anything you created when you 
lxd init)
You can add other networks by mentionning more than on network.
You can also choose the addresses of the other networks if you want.

### Managing Hosts
For Hosts, you should indicate the name, gateway and number of interfaces.
You should then indicate each interface configuration.
You can then add any command to be executed when the host starts up.
Be careful that the commands won't be interactive !
You can then modify the network configuration of your host, add packages, 
start services, etc.

Have fun networking !
