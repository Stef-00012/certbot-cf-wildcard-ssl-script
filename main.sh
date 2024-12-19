#!/bin/bash

CURRENT_PATH=$(dirname "$(readlink -f "$0")")
HOOK_DIRECTORY="$CURRENT_PATH/hooks"

echo "$CURRENT_PATH" > "$HOOK_DIRECTORY/path"

if [ -f "$CURRENT_PATH/.creds" ]; then
    echo "Reading credentials from $CURRENT_PATH/.creds"

    DOMAIN=$(grep DOMAIN "$CURRENT_PATH/.creds" | cut -d '"' -f 2)
    CONTACT=$(grep CONTACT "$CURRENT_PATH/.creds" | cut -d '"' -f 2)
    
    echo "Domain name: $DOMAIN"
fi

if [ -z "$DOMAIN" ]; then
    echo "missing domain in creds file"
    exit 0
fi

if [ -z "$CONTACT" ]; then
    echo "missing contact in creds file"
    exit 0
fi

certbot certonly -n --agree-tos --manual \
    --no-eff-email --preferred-challenges=dns \
    --manual-auth-hook "$HOOK_DIRECTORY/auth.sh" \
    --manual-cleanup-hook "$HOOK_DIRECTORY/clean.sh" \
    -m "$CONTACT" -d "$DOMAIN",*."$DOMAIN"