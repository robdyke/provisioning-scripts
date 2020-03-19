#!/bin/bash

set -o errexit

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

usage() {
  echo $"Usage: $0 {utils|vagrant|vbox|terraform|packer|all}"
  echo ""
}

# Package vars
PACKER_VER=1.5.4
TERRAFORM_VER=0.12.21
VBOX_VER=6.0
VAGRANT_VER=2.2.7

install_utils() {
  sudo apt-get install -y htop iotop iftop nmap tmux git vim unzip zip
}

install_vagrant() {
  PKGNAME=vagrant
  mkdir -p $ROOT_DIR/$PKGNAME && cd $ROOT_DIR/$PKGNAME
    wget https://releases.hashicorp.com/vagrant/${VAGRANT_VER}/vagrant_${VAGRANT_VER}_x86_64.deb -O vagrant.deb
    sudo dpkg -i ./vagrant.deb
    wget -q https://raw.github.com/brbsix/vagrant-bash-completion/master/vagrant-bash-completion/etc/bash_completion.d/vagrant
    sudo install -m 0644 vagrant /etc/bash_completion.d/ ||true
    vagrant version
  cd $ROOT_DIR && rm -rf $ROOT_DIR/$PKGNAME
}

install_terraform() {
  PKGNAME=terraform
  mkdir -p $ROOT_DIR/$PKGNAME && cd $ROOT_DIR/$PKGNAME
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip -O terraform.zip
    unzip terraform.zip
    sudo install terraform /usr/local/bin/terraform ||true
    terraform -install-autocomplete ||true
    terraform version
  cd $ROOT_DIR && rm -rf $ROOT_DIR/$PKGNAME
}

install_packer() {
  PKGNAME=packer
  mkdir -p $ROOT_DIR/$PKGNAME && cd $ROOT_DIR/$PKGNAME
    wget https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip -O packer.zip
    unzip packer.zip
    sudo install packer /usr/local/bin/packer ||true
    packer -autocomplete-install ||true
    packer version
  cd $ROOT_DIR && rm -rf $ROOT_DIR/$PKGNAME
}

install_virtualbox(){
  PKGNAME=vbox
  mkdir -p $ROOT_DIR/$PKGNAME && cd $ROOT_DIR/$PKGNAME
    curl -fSsl https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -
    curl -fSsl https://www.virtualbox.org/download/oracle_vbox.asc | sudo apt-key add -
    sudo add-apt-repository 'deb http://download.virtualbox.org/virtualbox/debian disco contrib'
    DEBIAN_FRONTEND=noninteractive sudo apt-get update
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y build-essential gcc make linux-headers-generic linux-headers-$(uname -r) dkms
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y virtualbox-${VBOX_VER}
  cd $ROOT_DIR && rm -rf $ROOT_DIR/$PKGNAME
}

case "$1" in
  utils)
    install_utils
    ;;
  vagrant)
    install_vagrant
    ;;
  vbox)
    install_virtualbox
    ;;
  terraform)
    install_terraform
    ;;
  packer)
    install_packer
    ;;
  all)
    install_utils
    install_virtualbox
    install_vagrant
    install_terraform
    install_packer
    ;;
  *)
    usage
    exit 1
    ;;
esac
