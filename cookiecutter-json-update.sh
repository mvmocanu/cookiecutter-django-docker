#!/bin/bash
set -euo pipefail
shopt -s extglob

update_field() {
  field="$1"
  value="$2"
  cookiecutter_json=$(cat cookiecutter.json | jq .$field=\"$value\" )
  echo "$cookiecutter_json" > cookiecutter.json
}

pip-compile --allow-unsafe --quiet cookiecutter-packages.in
update_field pip_version "$(grep 'pip==' cookiecutter-packages.txt | cut -d= -f3)"
update_field pip_tools_version "$(grep 'pip-tools==' cookiecutter-packages.txt | cut -d= -f3)"
update_field setuptools_version "$(grep 'setuptools==' cookiecutter-packages.txt | cut -d= -f3)"
rm cookiecutter-packages.txt

