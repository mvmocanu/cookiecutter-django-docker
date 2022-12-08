#!/bin/bash
set -euxo pipefail
shopt -s extglob

pip-compile --allow-unsafe cookiecutter-packages.in

COOKIECUTTER_JSON=$(cat cookiecutter.json \
 | jq .pip_version=\"$(grep 'pip==' cookiecutter-packages.txt | cut -d= -f3)\" \
 | jq .pip_tools_version=\"$(grep 'pip-tools==' cookiecutter-packages.txt | cut -d= -f3)\" \
 | jq .setuptools_version=\"$(grep 'setuptools==' cookiecutter-packages.txt | cut -d= -f3)\")

echo "$COOKIECUTTER_JSON" > cookiecutter.json

rm cookiecutter-packages.txt
