#!/bin/bash
set -xeuo pipefail
ls -al requirements
for req in requirements/*.in; do
  pip-compile --generate-hashes --allow-unsafe --quiet --upgrade $req
done
