#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions
echo "api decypher"
gpg -help
gpg --quiet --batch --yes --decrypt --passphrase="$API_JSON_FILE_DECRYPTKEY" \
--output ./api-4712693179220384697-162836-33ea08672303.json api-4712693179220384697-162836-33ea08672303.json.gpg
ls
echo "keystore decypher"
gpg --quiet --batch --yes --decrypt --passphrase='$DECRYPT_GPG_KEYSTORE' --output ./keystore.jks scanner_keystore.jks.gpg
ls