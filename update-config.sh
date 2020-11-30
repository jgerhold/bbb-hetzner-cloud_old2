#!/bin/bash

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  --hcloud-token)
    TOKEN="$2"
    shift
    shift
  ;;
  --floating-ips)
    FLOATING_IPS="1"
    shift
  ;;
  *)
    shift
  ;;
esac
done

# NEW_NODE_IPS=( $(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/servers' | jq -r '.servers[].public_net.ipv4.ip') )

# touch /etc/current_node_ips
# cp /etc/current_node_ips /etc/old_node_ips
# echo "" > /etc/current_node_ips

# for IP in "${NEW_NODE_IPS[@]}"; do
#   ufw allow from "$IP"
#   echo "$IP" >> /etc/current_node_ips
# done

# IFS=$'\r\n' GLOBIGNORE='*' command eval 'OLD_NODE_IPS=($(cat /etc/old_node_ips))'

# REMOVED=()
# for i in "${OLD_NODE_IPS[@]}"; do
#   skip=
#   for j in "${NEW_NODE_IPS[@]}"; do
#     [[ $i == $j ]] && { skip=1; break; }
#   done
#   [[ -n $skip ]] || REMOVED+=("$i")
# done
# declare -p REMOVED

# for IP in "${REMOVED[@]}"; do
#   ufw deny from "$IP"
# done

FLOATING_IPS=${FLOATING_IPS:-"0"}

# if [ "$FLOATING_IPS" == "1" ]; then
#   FLOATING_IPS=( $(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/floating_ips' | jq -r '.floating_ips[].ip') )

#   for IP in "${FLOATING_IPS[@]}"; do
#     ip addr add $IP/32 dev eth0
#   done
# fi

if [ "$FLOATING_IPS" == "1" ]; then
  # FLOATING_IPS=( $(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/floating_ips' | jq -r '.floating_ips[] | {(.type):.ip}') )
  FLOATING_IPS=( $(curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" 'https://api.hetzner.cloud/v1/floating_ips' | jq -r '.floating_ips[] | @base64') )
  for IP in "${FLOATING_IPS[@]}"; do
    # IPTYPE=$(echo $IP | base64 --decode | jq -r '.type')
    IPNAME=$(echo $IP | base64 --decode | jq -r '.name')
    IPVALUE=$(echo $IP | base64 --decode | jq -r '.ip')
    echo ADDING ${IPNAME}: ${IPVALUE}
    case $IPNAME in
      bbb-wsmh-spe-ipv4)
        ip addr add ${IPVALUE}/32 dev eth0
        ;;
      bbb-wsmh-spe-ipv6)
        ip addr add $(echo ${IPVALUE} | sed -e 's/\/64/1\/128/') dev eth0
        ;;
      *)
        echo -n "unknow ip type"
        ;;
    esac
    #ip addr add $IP/32 dev eth0
    #ip addr add 2a01:4f8:2c17:2c::1/128 dev eth0
  done
fi
