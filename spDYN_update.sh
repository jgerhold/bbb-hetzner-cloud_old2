#!/bin/sh
#
# Script for updating spDYN dynamic DNS entries (https://spdyn.de)
#
# Usage:
#   - Save this script as $HOME/bin/spDYN_update.sh
#   - Make it executable: chmod u+x $HOME/bin/spDYN_update.sh
#   - Create a cron entry (crontab -e) and supply <HOST_NAME> and <UPDATE_TOKEN>
#     according to your spDYN settings. Example for running every 10 minutes:
#       */10 * * * * $HOME/bin/spDYN_update.sh <HOST_NAME> <UPDATE_TOKEN> > /dev/null
#
# Logs are written to $HOME/.spDYN/
#
# spDYN_update.sh, Copyright 2017 Harald Aigner <harald.aigner@gmx.net>
# Licensed under the GPLv3 (https://www.gnu.org/licenses/gpl-3.0.txt)

if [ $# -ne 2 ]
then
  echo "Usage: $0 <HOST_NAME> <UPDATE_IPV4_TOKEN> <UPDATE_IPV6_TOKEN>"
fi

HOST_NAME=$1
UPDATE_TOKEN=$2
UPDATE6_TOKEN=$3
DATE=`date "+%Y-%m-%d %H:%M:%S"`
UPDATE_URL="https://update.spdyn.de/nic/update"
CHECK_IP_URL="http://checkip4.spdyn.de"
CHECK_IP6_URL="http://checkip6.spdyn.de"

ip_file="${HOME}/.spDYN/4-${HOST_NAME}"
ip6_file="${HOME}/.spDYN/6-${HOST_NAME}"
log_file="${HOME}/.spDYN/${HOST_NAME}.log"
old_ip="<not available>"
old_ip6="<not available>"

if [ -r ${ip_file} ]
then
  old_ip=$(cat ${ip_file})
else
  mkdir -p "${HOME}/.spDYN"
fi

if [ -r ${ip6_file} ]
then
  old_ip6=$(cat ${ip6_file})
else
  mkdir -p "${HOME}/.spDYN"
fi

ip=$(curl -s ${CHECK_IP_URL})
ip6=$(curl -s ${CHECK_IP6_URL})
if [ -z "${ip}" ]
then
  echo "${DATE}: error retrieving IP" | tee -a "${log_file}"
  exit 1
fi
if [ "${ip}" = "${old_ip}" ]
then
  echo "${DATE}: no IP change (${ip})" | tee -a "${log_file}"
  exit 0
fi

if [ -z "${ip6}" ]
then
  echo "${DATE}: error retrieving IP6" | tee -a "${log_file}"
  exit 1
fi
if [ "${ip6}" = "${old_ip6}" ]
then
  echo "${DATE}: no IP6 change (${ip6})" | tee -a "${log_file}"
  exit 0
fi


echo "${DATE}: detected new IP: ${old_ip} -> ${ip}" | tee -a "${log_file}"
echo "${ip}" > "${ip_file}"
echo "${DATE}: wrote new IP to ${ip_file}" | tee -a "${log_file}"
response=$(curl -su "${HOST_NAME}:${UPDATE_TOKEN}" "${UPDATE_URL}?hostname=${HOST_NAME}&myip=${ip}")
echo "${DATE}: response: ${response}" | tee -a "${log_file}"


echo "${DATE}: detected new IP6: ${old_ip6} -> ${ip6}" | tee -a "${log_file}"
echo "${ip6}" > "${ip6_file}"
echo "${DATE}: wrote new IP to ${ip6_file}" | tee -a "${log_file}"
response=$(curl -su "${HOST_NAME}:${UPDATE6_TOKEN}" "${UPDATE_URL}?hostname=${HOST_NAME}&myip=${ip6}")
echo "${DATE}: response: ${response}" | tee -a "${log_file}"
