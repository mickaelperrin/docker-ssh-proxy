#!/usr/bin/env bash
set -e

## Ensure correct time-zone is set
## -------------------------------
if [ -z ${TZ} ]; then
  export TZ="Europe/Paris"
fi

if [ -f /usr/share/zoneinfo/${TZ} ]; then
  cp -f /usr/share/zoneinfo/${TZ} /etc/localtime
  echo "${TZ}" > /etc/timezone
fi

## Run only in classic startup (not when entering the container)
## -------------------------------------------------------------
if [ "$1" = '/go/bin/sshpiperd' ]; then

  ## Run additional startup scripts
  ## ------------------------------
  for f in /docker-entrypoint.d/*; do
      case "$f" in
          *.sh)     echo "$0: running $f"; . "$f" ;;
          *)        echo "$0: ignoring $f" ;;
      esac
  done

  if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ""
  fi

  # Restart process if config file has changed
  # ------------------------------------------
  while inotifywait -q -e create,delete,modify,attrib /etc/sshpiper/docker.generated.conf; do
    echo
    echo "-----------------------------------------"
    echo
    echo "Config has changed. Restarting service..."
    echo
    /generateConfig.sh
    [ -z "${PID}" ] || kill ${PID}
    /go/bin/sshpiperd &
    PID=$!
  done
fi

exec "$@"

