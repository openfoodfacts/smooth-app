#!/bin/bash
for file in *.arb
do
  locale=${file/intl_/}
  locale=${locale/.arb/}
  echo $locale
  sed "s|[\"]en[\"]|\"$locale\"|" "$file" > tempfile$$ &&
  mv tempfile$$ "$file"
done
