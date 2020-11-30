#!/bin/bash

hcloud server create --name <turnservername> --image ubuntu-18.04 --type cpx11 --ssh-key joel@gmx.de --datacenter nbg1-dc3 --user-data-from-file ./cloud-config-turn.yml

hcloud server create --name <servername> --image ubuntu-16.04 --type <servertype> --ssh-key <email> --datacenter <datacenter> --user-data-from-file ./cloud-config.yml --start-after-create=false

hcloud floating-ip assign <failover-ip-name> <servername>

hcloud server poweron <servername>

