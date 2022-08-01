#!/bin/bash
set -e
CHANGES=""

for HOST in ${DNS_HOSTNAMES//,/  }
do
  echo "Evaluating $HOST"
  TARGET_IP=`dig $HOST | tail -n 1`

  if [[ -n $TARGET_IP ]]; then
    echo "Setting $HOST DNS to $TARGET_IP"
    CHANGES="{\"Action\": \"UPSERT\", \"ResourceRecordSet\": {\"Name\": \"$HOST.$DNS_DOMAIN.\", \"Type\": \"A\", \"TTL\": 300, \"ResourceRecords\": [{\"Value\": \"$TARGET_IP\"}]}},$CHANGES"
  else
    echo "No IP Address found for $HOST, skipping..."
  fi

  echo " "
done

if [[ -n $CHANGES ]]; then
  CHANGES=${CHANGES::-1}
  aws route53 change-resource-record-sets --hosted-zone-id $AWS_ROUTE53_ZONE_ID --change-batch "{\"Changes\": [$CHANGES]}"
  echo "Changes complete"
else
  echo "No changes found"
fi
