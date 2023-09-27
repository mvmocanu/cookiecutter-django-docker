#!/bin/bash -eux
ls -al requirements
for req in requirements/*.in; do
  pip-compile --generate-hashes --allow-unsafe --quiet --upgrade --strip-extras --resolver=backtracking $req
done
