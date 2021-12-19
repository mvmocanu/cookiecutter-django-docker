#!/bin/bash
set -euxo pipefail

for extra in ${POSTGRES_EXTRAS:-}; do
    psql --username "$POSTGRES_USER" --dbname "postgres" <<-EOSQL
        CREATE USER $extra WITH PASSWORD '$extra';
        CREATE DATABASE $extra;
        GRANT ALL PRIVILEGES ON DATABASE $extra TO $extra;
EOSQL
    # Force a reassign in case something was misconfigured in the past
    psql --username "$POSTGRES_USER" --dbname "$extra" <<-EOSQL
        DO \$\$
        DECLARE r record;
        BEGIN
            FOR r IN
                select 'ALTER TABLE "' || table_schema || '"."' || table_name || '" OWNER TO $extra;' as a
                    from information_schema.tables where table_schema = 'public'
                    union all
                select 'ALTER TABLE "' || sequence_schema || '"."' || sequence_name || '" OWNER TO $extra;' as a
                    from information_schema.sequences where sequence_schema = 'public'
                    union all
                select 'ALTER TABLE "' || table_schema || '"."' || table_name || '" OWNER TO $extra;' as a
                    from information_schema.views where table_schema = 'public'
                    union all
                select 'ALTER FUNCTION "' || nsp.nspname || '"."' || p.proname || '"(' || pg_get_function_identity_arguments(p.oid) || ') OWNER TO $extra;' as a
                    from pg_proc p join pg_namespace nsp ON p.pronamespace = nsp.oid where nsp.nspname = 'public'
                    union all
                select 'ALTER DATABASE $extra OWNER TO $extra;'
            LOOP
                EXECUTE r.a;
            END LOOP;
        END \$\$;
EOSQL
done
