#!/bin/bash

# Translated .arb files from CrowdIn (e.g. intl_fr_FR.arb) currently all have their
# locale set to "en" (English) : "@@locale": "en"
# This script replaces the "en" by the locale included in the file name.
# It needs to be run in the directory where the incorrect .arb files are.

for file in *.arb
do
  locale=${file/intl_/}
  locale=${locale/.arb/}
  echo $locale
  sed "s|locale[\"]: [\"]en[\"]|locale\": \"$locale\"|" "$file" > tempfile$$ &&
  mv tempfile$$ "$file"
done
