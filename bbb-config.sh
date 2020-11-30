#!/bin/bash

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
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
  *)
    shift
  ;;
esac
done

cd greenlight/
# docker exec greenlight-v2 bundle exec rake admin:create
docker exec greenlight-v2 bundle exec rake admin:create["${ADMINNAME}","${ADMINEMAIL}","${ADMINPW}"]
