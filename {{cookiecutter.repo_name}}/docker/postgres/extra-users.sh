#!/bin/bash -eux

for extra in ${POSTGRES_EXTRAS:-}; do
    psql postgres <<-EOSQL
        CREATE USER $extra WITH PASSWORD '$extra';
        CREATE DATABASE $extra;
        GRANT ALL PRIVILEGES ON DATABASE $extra TO $extra;
EOSQL
done
