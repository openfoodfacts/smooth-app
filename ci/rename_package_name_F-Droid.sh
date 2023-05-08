#!/bin/bash
set -e


# Replaces all occurrences of org.openfoodfacts.scanner -> openfoodfacts.github.scrachx.openfood for the F-Droid listing

cd ../packages/smooth_app/android/ && grep -rli 'org.openfoodfacts.scanner' * | xargs -i@ sed -i 's/org.openfoodfacts.scanner/openfoodfacts.github.scrachx.openfood/g' @
