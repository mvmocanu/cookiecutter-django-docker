#!/bin/bash
set -euxo pipefail
shopt -s extglob

update_field() {
  field="$1"
  value="$2"
  cookiecutter_json=$(cat cookiecutter.json | jq ._$field=\"$value\" | jq ".__prompts__.$field=\"$field (latest=$value)\"" )
  echo "$cookiecutter_json" > cookiecutter.json
}

uv pip compile --allow-unsafe --quiet cookiecutter-packages.in --output-file=cookiecutter-packages.txt
update_field uv_version "$(grep 'uv==' cookiecutter-packages.txt | cut -d= -f3)"
update_field django_version "$(grep 'django==' cookiecutter-packages.txt | cut -d= -f3 | cut -d. -f1-2)"
update_field pip_version "$(grep 'pip==' cookiecutter-packages.txt | cut -d= -f3)"
update_field pip_tools_version "$(grep 'pip-tools==' cookiecutter-packages.txt | cut -d= -f3)"
update_field setuptools_version "$(grep 'setuptools==' cookiecutter-packages.txt | cut -d= -f3)"
rm cookiecutter-packages.txt

