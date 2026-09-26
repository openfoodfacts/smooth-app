#!/bin/sh

# Decrypt secrets for multiple Open*Facts apps
# This script handles both the API JSON file and the appropriate keystore
# based on the KEYSTORE_FILE environment variable.

# --batch to prevent interactive command
# --yes to assume "yes" for questions
echo "api decypher"
gpg --quiet --batch --yes --decrypt --passphrase="$API_JSON_FILE_DECRYPTKEY" \
--output ./api-4712693179220384697-162836-33ea08672303.json api-4712693179220384697-162836-33ea08672303.json.gpg

echo "keystore decypher for $KEYSTORE_FILE"
# Determine which encrypted keystore file to use based on KEYSTORE_FILE
if [ "$KEYSTORE_FILE" = "obf_keystore.jks" ]; then
    # Open Beauty Facts and Open Pet Food Facts use the OBF keystore
    gpg --quiet --batch --yes --decrypt --passphrase="$STORE_JKS_DECRYPTKEY" \
    --output ./obf_keystore.jks obf_keystore.jks.gpg
else
    # Open Food Facts and Open Products Facts use the standard keystore
    gpg --quiet --batch --yes --decrypt --passphrase="$STORE_JKS_DECRYPTKEY" \
    --output ./keystore.jks keystore.jks.gpg
fi
