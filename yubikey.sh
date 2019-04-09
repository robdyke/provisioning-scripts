#!/bin/bash

set -o errexit

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

usage() {
  echo $"Usage: $0 {install}"
  echo ""
}

install_udevrules() {
  echo "INFO: Installing Yubikey udev rules"
  sudo cp ./files/70-u2f.rules.txt /etc/udev/rules.d//70-u2f.rules
  sudo udevadm control --reload-rules
}

case "$1" in
  install)
    install_udevrules
    ;;
  *)
    usage
    exit 1
    ;;
esac
