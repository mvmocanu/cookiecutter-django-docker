{% raw -%}
#!/bin/bash
set -euo pipefail
shopt -s extglob

if [ -z "$RELOADER_MONITOR" ]; then
    echo -e "\033[1;33m[$(date -Iseconds)] Reloader is disabled. Exiting ...\033[0m"
    exit 0
fi

while true; do
    echo -e "\033[1;32m[$(date -Iseconds)] Waiting for changes ...\033[0m"
    (
        set -x
        fswatch \
            --recursive \
            --extended \
            --exclude '\.git|__pycache__|\.pyc|\.egg-info|___jb_|\..+~$' \
            --event Created \
            --event Updated \
            --event Removed \
            --event Renamed \
            --event OwnerModified \
            --event AttributeModified \
            --event MovedFrom \
            --event MovedTo \
            --one-per-batch \
            --monitor ${RELOADER_MONITOR:-inotify}_monitor \
            /app/src/
    ) | while read event; do
        echo -e "\033[1;36m[$(date -Iseconds)] Detected $event changes.\033[0m "
        if [[ $event =~ .*/static(/|$) ]]; then
            echo -e "\033[1;34m[$(date -Iseconds)] Running collectstatic ..."
            (
                set -x
                docker exec ${COMPOSE_PROJECT_NAME}_web_1 pysu app django-admin collectstatic --no-input -v0
            ) || echo -e "\033[1;31m[$(date -Iseconds)] Failed to run collectstatic!"
        else
            echo -e "\033[1;34m[$(date -Iseconds)] Attempting restarts ..."
            /bin/echo r 1<>/var/app/run/uwsgi.fifo >/var/app/run/uwsgi.fifo || echo -e "\033[31muWSGI is not running!"
            pids=()
            for name in $(docker ps --format '{{ .Names }}' | egrep "^$COMPOSE_PROJECT_NAME[-_]($RELOADER_CONTAINERS)"); do
                (set -x; docker restart $name) &
                pids+=($!)
            done
            wait "${pids[@]}"
        fi
    done
done
{%- endraw %}
