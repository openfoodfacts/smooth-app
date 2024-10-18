#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# -----------------------------------
# First step: copy-paste README.md to doc
# -----------------------------------

cp ./README.md ./doc/README.md

# Build mkdocs
poetry run mkdocs build --strict
