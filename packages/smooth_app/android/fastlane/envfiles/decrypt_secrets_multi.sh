#!/bin/sh

# Decrypt secrets for multiple Open*Facts apps
# This script handles both the API JSON file and the appropriate keystore
# based on the KEYSTORE_FILE environment variable.

# --batch to prevent interactive command
# --yes to assume "yes" for questions

# Determine the API JSON file based on PACKAGE_NAME (if provided)
# For now, all apps use the same OFF API JSON file
# TODO: Add support for separate API JSON files per app when available
API_JSON_FILE="api-4712693179220384697-162836-33ea08672303.json"

echo "api decypher for ${API_JSON_FILE}"
gpg --quiet --batch --yes --decrypt --passphrase="$API_JSON_FILE_DECRYPTKEY" \
--output ./${API_JSON_FILE} ${API_JSON_FILE}.gpg

echo "keystore decypher for $KEYSTORE_FILE"
# Determine which encrypted keystore file to use based on KEYSTORE_FILE
if [ "$KEYSTORE_FILE" = "obf_keystore.jks" ]; then
    # Open Beauty Facts and Open Pet Food Facts use the scanner keystore
    # TODO: This should be renamed to obf_keystore.jks.gpg once the file is properly migrated
    gpg --quiet --batch --yes --decrypt --passphrase="$STORE_JKS_DECRYPTKEY" \
    --output ./obf_keystore.jks scanner_keystore.jks.gpg
else
    # Open Food Facts and Open Products Facts use the standard keystore
    gpg --quiet --batch --yes --decrypt --passphrase="$STORE_JKS_DECRYPTKEY" \
    --output ./keystore.jks keystore.jks.gpg
fi
