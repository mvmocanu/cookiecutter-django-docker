#!/bin/bash
set -euxo pipefail

if [[ "$@" == "--help" || "$@" == "-h" ]]; then
    set +x
    echo "
Usage: ./test.sh command-to-run arguments

Examples:

- run the default (pytest):

    ./test.sh

- run pytest with arguments:

    ./test.sh pytest -k mytest

- make migrations:

    ./test.sh django-admin makemigrations

- do interactive stuff:

    ./test.sh bash

- update the requirements (also automatically run if you don't have any requirements/*.txt):

    ./test.sh requirements

- disable building:

    NOBUILD=1 ./test.sh

- disable service teardown (faster but less safe runs):

    NOCLEAN=1 ./test.sh
"
    exit 0
fi

export COMPOSE_PROJECT_NAME="test{{ cookiecutter.compose_project_name }}"
export COMPOSE_FILE=docker-compose.test.yml

USER="${USER:-$(id -nu)}"
if [[ "$(uname)" == "Darwin" ]]; then
    USER_UID=1000
    USER_GID=1000
else
    USER_UID="$(id --user "$USER")"
    USER_GID="$(id --group "$USER")"
fi

if [[ -z "$(find requirements -maxdepth 1 -name '*.txt' -print -quit)" ]] || [[ "$*" == "requirements" ]]; then
    set -x
    docker compose build --build-arg "USER_UID=$USER_UID" --build-arg "USER_GID=$USER_GID" requirements
    docker compose run --rm --user=$USER_UID requirements
    if [[ "$*" == "requirements" ]]; then
        exit
    fi
    set +x
fi

if [[ -z "${NOBUILD:-}" ]]; then
    docker compose build --build-arg "USER_UID=$USER_UID" --build-arg "USER_GID=$USER_GID" test
fi
if [[ -z "$*" ]]; then
    set -- pytest
fi

homedir=$(dirname ${BASH_SOURCE[0]})/.home
if [[ ! -e $homedir ]]; then
    # create it here so Docker don't create with root ownership
    mkdir $homedir
fi

function cleanup() {
    echo "Cleaning up ..."
    docker compose down && docker compose rm -fv
}
if [[ -n "${NODEPS:-}" ]]; then
    exec docker compose run -e NODEPS=yes --no-deps --rm --user=$USER_UID test "$@"
else
    if [[ -z "${NOCLEAN:-}" ]]; then
        trap cleanup EXIT
        cleanup || echo "Already clean :-)"
    fi
    docker compose run --rm --user=$USER_UID test "$@"
fi
