#!/bin/bash

CURRENT_PATH=$(dirname "$(readlink -f "$0")")
BASE_PATH=$(cat "$CURRENT_PATH/path")
HOOK_DIRECTORY="$BASE_PATH/hooks"

API_KEY=$(grep API_KEY "$BASE_PATH/.creds" | cut -d '"' -f 2)

if [ -f "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/ZONE_ID" ]; then
    ZONE_ID=$(cat "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/ZONE_ID")
    rm -f "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/ZONE_ID"
fi

if [ -f "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/RECORD_ID" ]; then
    RECORD_IDS=$(cat "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/RECORD_ID")
    rm -f "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/RECORD_ID"
fi

# Remove the challenge TXT record from the zone
if [ -n "${ZONE_ID}" ]; then
    if [ -n "${RECORD_IDS}" ]; then
        for RECORD_ID in $RECORD_IDS; do
            curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
                -H "Authorization: Bearer $API_KEY" \
                -H "Content-Type: application/json"
        done
    fi
fi

rm "$HOOK_DIRECTORY/path"