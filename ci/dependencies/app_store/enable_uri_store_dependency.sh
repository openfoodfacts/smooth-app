#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

SEDOPTION=
if [[ "$OSTYPE" == "darwin"* ]]; then
  SEDOPTION="-i ''"
fi

sed $SEDOPTION 's|^  #app_store_uri|  app_store_uri|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^    #path: ../app_store/uri_store|    path: ../app_store/uri_store|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^  app_store_apple_store|  #app_store_apple_store|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^    path: ../app_store/apple_app_store|    #path: ../app_store/apple_app_store|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^  app_store_google_play|  #app_store_google_play|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^    path: ../app_store/google_play|    #path: ../app_store/google_play|g' packages/app/pubspec.yaml