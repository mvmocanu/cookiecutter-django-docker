#!/bin/bash
set -xeuo pipefail
ls -al requirements
for req in requirements/*.in; do
  pip-compile -U $req --generate-hashes --allow-unsafe --quiet
done
