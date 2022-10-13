#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$AUTH_KEY_FILE_DECRYPTKEY" \
--output ./AuthKey_KDAUTTM76R.p8 AuthKey_KDAUTTM76R.p8.gpg