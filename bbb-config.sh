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


cat << EOF >> /etc/bigbluebutton/bbb-conf/apply-config.sh

echo "  - Setting camera defaults"
yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==low).bitrate' 50
yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==medium).bitrate' 75
yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==high).bitrate' 100
yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==hd).bitrate' 100

yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==low).default' true
yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==medium).default' false
yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==high).default' false
yq w -i $HTML5_CONFIG 'public.kurento.cameraProfiles.(id==hd).default' false

EOF

bbb-conf --restart
