#!/bin/bash -eux
exec pysu app yacron --config=/etc/app/yacron.yml "$@"
