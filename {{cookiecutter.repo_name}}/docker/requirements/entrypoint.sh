#!/bin/bash -eux
ls -al requirements
for req in requirements/*.in; do
{% if cookicutter.uv_enabled %}
  uv pip compile --generate-hashes --allow-unsafe --quiet --upgrade --strip-extras --resolver=backtracking $req --output-file=${req%.*}.txt
{% else %}
  pip-compile --generate-hashes --allow-unsafe --quiet --upgrade --strip-extras --resolver=backtracking $req
{% endif %}
done
