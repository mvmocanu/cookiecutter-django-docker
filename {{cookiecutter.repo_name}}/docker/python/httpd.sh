#!/bin/bash -eux
if [[ -z "$*" ]]; then
  set -- -e info
fi
exec apache2 -f /etc/app/httpd.conf -DFOREGROUND "$@"
