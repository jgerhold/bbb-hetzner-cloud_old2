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
  --domain)
    DOMAIN="$2"
    shift
    shift
  ;;
  --email)
    EMAIL="$2"
    shift
    shift
  ;;
  --admin-name)
    ADMINNAME="$2"
    shift
    shift
  ;;
  --admin-email)
    ADMINEMAIL="$2"
    shift
    shift
  ;;
  --admin-password)
    ADMINPW="$2"
    shift
    shift
  ;;
  --turn-domain-secret)
    TURNDOMAINSECRET="$2"
    shift
    shift
  ;;
  --turn)
    TURNDOMAIN="$2"
    shift
    shift
  ;;
  --spdns-token4)
    SPDNSTOKEN4="$2"
    shift
    shift
  ;;
  --spdns-token6)
    SPDNSTOKEN6="$2"
    shift
    shift
  ;;
  --floating-ips)
    FLOATING_IPS="--floating-ips"
    shift
  ;;
  *)
    shift
  ;;
esac
done

FLOATING_IPS=${FLOATING_IPS:-""}
TURNDOMAIN=${TURNDOMAIN:-"0"}
SPDNSTOKEN4=${SPDNSTOKEN4:-""}
SPDNSTOKEN6=${SPDNSTOKEN6:-""}

sed -i 's/[#]*PermitRootLogin yes/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
sed -i 's/[#]*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

systemctl restart sshd

wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x jq-linux64
mv jq-linux64 /usr/local/bin/jq

if [ "$TURNDOMAIN" != "0" ]; then
curl -o /usr/local/bin/spDYN_update.sh https://raw.githubusercontent.com/jgerhold/bbb-hetzner-cloud/main/spDYN_update.sh
chmod +x /usr/local/bin/spDYN_update.sh

/usr/local/bin/spDYN_update.sh ${TURNDOMAIN} ${SPDNSTOKEN4} ${SPDNSTOKEN6}

wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- -c ${TURNDOMAINSECRET} -e ${EMAIL} -l
else
curl -o /usr/local/bin/update-config.sh https://raw.githubusercontent.com/jgerhold/bbb-hetzner-cloud/main/update-config.sh

chmod +x /usr/local/bin/update-config.sh

/usr/local/bin/update-config.sh --hcloud-token ${TOKEN} ${FLOATING_IPS}

#  -c <hostname>:<secret> Configure with coturn server at <hostname> using <secret>
wget -qO- https://ubuntu.bigbluebutton.org/bbb-install.sh | bash -s -- -w -g -v xenial-22 -s ${DOMAIN} -e ${EMAIL} -c ${TURNDOMAINSECRET}

curl -o /usr/local/bin/bbb-config.sh https://raw.githubusercontent.com/jgerhold/bbb-hetzner-cloud/main/bbb-config.sh

chmod +x /usr/local/bin/bbb-config.sh

/usr/local/bin/bbb-config.sh --admin-name ${ADMINNAME} --admin-email ${ADMINEMAIL} --admin-password ${ADMINPW}
fi

# sudo bbb-conf --check
# sudo bbb-conf --setip ${DOMAIN}
