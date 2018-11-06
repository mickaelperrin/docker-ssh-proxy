#!/usr/bin/env bash
set -e

PID=

while [ -z "${PID}" ]; do
  PID=$(pgrep sshpiper)
  sleep 1
done

# Restart process if config file has changed
# ------------------------------------------
while inotifywait -q -e create,delete,modify,attrib /etc/sshpiper/docker.generated.conf; do
  echo
  echo "-----------------------------------------"
  echo
  echo "Config has changed. Restarting service..."
  echo
  /generateConfig.sh
  kill ${PID}
  PID=
  while [ -z "${PID}" ]; do
    PID=$(pgrep sshpiper)
    sleep 1
  done
done