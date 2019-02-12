#!/bin/bash
set -o nounset
set -o errexit

# Android prep script


# Silent mode hook
SILENT=false
if [[ "$1" == "--silent" ]]; then
  SILENT=true
fi

log() {
  if ! $SILENT; then
    echo $1
  fi
}

run_command() {
  if $SILENT; then
    $1 &>/dev/null
  else
    $1
  fi
}



# Configuring VM acceleration on Linux
install_kvm(){
  INSTALL_CMD="sudo apt-get install -y qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils ia32-libs-multiarch || { echo \"command failed\"; exit 1; }"
  run_command "$INSTALL_CMD"
}
