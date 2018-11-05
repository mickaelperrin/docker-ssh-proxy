#!/usr/bin/env bash
set -e

CONFIG_DIR=/var/sshpiper
CONFIG_FILE_PATH=/etc/sshpiper/docker.generated.conf

init() {
  # Remove existing configuration
  if  [ -d ${CONFIG_DIR} ]; then
    rm -rf ${CONFIG_DIR}/*
  fi
  # Ensure configuration folder exists
  mkdir -p ${CONFIG_DIR}
}

createConfig() {
  local user=$1
  local redirect=$2

  mkdir -p ${CONFIG_DIR}/${user}
  cat > ${CONFIG_DIR}/${user}/sshpiper_upstream <<EOF
${2}
EOF
  chmod -R og-rwx ${CONFIG_DIR}/${user}
}

#
# Config file is in the following format
# user|username@target:port
#
parseConfigFile() {
  local user=
  local redirect=

  while IFS='' read -r line || [[ -n "$line" ]]; do
    user=$(echo "$line" |  awk -F \| '{ print $1 }' )
    redirect=$(echo "$line" |  awk -F \| '{ print $2 }' )
    createConfig "$user" "$redirect"
  done < ${CONFIG_FILE_PATH}
}

# Ensure that config file exists
if [ ! -f ${CONFIG_FILE_PATH} ]; then
   touch ${CONFIG_FILE_PATH}
   exit 0
fi

init
parseConfigFile