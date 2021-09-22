#!/bin/bash -eu
mkdir -p /app/run /app/static
chown -R app:app /app/run /app/static
# Fill in defaults if /etc/app is an empty volume
for path in /etc/app-defaults/*; do
  name=$(basename "$path")
  if [[ ! -e "/etc/app/$name" ]]; then
    echo "+ ln /etc/app-defaults/$name /etc/app/$name"
    ln -s "/etc/app-defaults/$name" "/etc/app/$name"
  fi
done
if [[ -n "${DJANGO_COLLECTSTATIC:-}" ]]; then
  pysu app django-admin collectstatic --noinput --clear -v0
fi
holdup --verbose pg://$DJANGO_DB_USER:$DJANGO_DB_PASSWORD@$DJANGO_DB_HOST:5432/$DJANGO_DB_NAME
if [[ -n "${DJANGO_DB_MIGRATE:-}" ]]; then
  pysu app django-admin migrate --noinput --fake-initial
fi
set -x
exec "$@"
