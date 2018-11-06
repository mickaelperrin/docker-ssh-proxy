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
if [ "$1" = 'forego' ]; then

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
fi

exec "$@"

