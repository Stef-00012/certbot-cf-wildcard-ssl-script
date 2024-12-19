#!/bin/bash

CURRENT_PATH=$(dirname "$(readlink -f "$0")")
BASE_PATH=$(cat "$CURRENT_PATH/path")
HOOK_DIRECTORY="$BASE_PATH/hooks"

API_KEY=$(grep API_KEY "$BASE_PATH/.creds" | cut -d '"' -f 2)
ZONE_ID=$(grep ZONE_ID "$BASE_PATH/.creds" | cut -d '"' -f 2)

CREATE_DOMAIN="_acme-challenge.$CERTBOT_DOMAIN"

curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    --data '{"type":"TXT","name":"'"$CREATE_DOMAIN"'","content":"'"$CERTBOT_VALIDATION"'","ttl":120}'

RECORD_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=TXT&name=$CREATE_DOMAIN" \
    -H "Content-Type:application/json" \
    -H "Authorization: Bearer $API_KEY" |
    grep -oE "\"id\":\"\w+\"" |
    cut -d '"' -f 4)

# Create a directory for storing temporary files if it doesn't exist
if [ ! -d "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT" ]; then
    mkdir -pm 0700 "$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT"
fi

# Write the zone ID and record ID to temporary files
echo "$ZONE_ID" >"$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/ZONE_ID"
echo "$RECORD_ID" >"$HOOK_DIRECTORY/$CERTBOT_DOMAIN/CERTBOT/RECORD_ID"

# Wait for 15 seconds - this is the time it takes for the DNS record to be updated
sleep 15