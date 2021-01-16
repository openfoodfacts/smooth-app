#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$ANDROID_KEYS_SECRET_PASSPHRASE" \
--output android/android_keys.zip android/android_keys.zip.gpg && cd android && jar xvf android_keys.zip && cd -
