#!/bin/bash -eu
for name in /etc/app-defaults/*; do
  name=$(basename "$name")
  if [[ ! -e "/etc/app/$name" ]]; then
    echo "+ cp /etc/app-defaults/$name /etc/app/$name"
    cp "/etc/app-defaults/$name" "/etc/app/$name"
  fi
done
holdup --verbose pg://$DJANGO_DB_USER:$DJANGO_DB_PASSWORD@$DJANGO_DB_HOST:5432/$DJANGO_DB_NAME
if [[ -n "${DJANGO_DB_MIGRATE:-}" ]]; then
  pysu app django-admin migrate --noinput --fake-initial
fi
set -x
exec "$@"
