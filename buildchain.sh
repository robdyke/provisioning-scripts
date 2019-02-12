#!/bin/bash

set -o errexit

usage() {
  echo $"Usage: $0 {utils|node|ruby}"
  echo ""
}

PACKER_VER=1.3.3
TERRAFORM_VER=0.11.11
VBOX_VER=6.0

install_utils() {
  sudo apt install -y htop iotop iftop nmap tmux git vim unzip zip
}

install_vagrant() {
  wget https://releases.hashicorp.com/vagrant/2.2.2/vagrant_2.2.2_x86_64.deb
  sudo dpkg -i vagrant_2.2.2_x86_64.deb
  wget -q https://raw.github.com/brbsix/vagrant-bash-completion/master/vagrant-bash-completion/etc/bash_completion.d/vagrant
  sudo install -m 0644 vagrant /etc/bash_completion.d/
  vagrant version
  rm ./vagrant_2.2.2_x86_64.deb
}

install_terraform() {
  rm ./terraform.zip ./terraform
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VER}/terraform_${TERRAFORM_VER}_linux_amd64.zip -O terraform.zip
  unzip terraform.zip
  sudo install terraform /usr/local/bin/terraform
  terraform -install-autocomplete
  terraform version
  rm ./terraform.zip ./terraform
}

install_packer() {
  rm ./packer.zip ./packer
  wget https://releases.hashicorp.com/packer/${PACKER_VER}/packer_${PACKER_VER}_linux_amd64.zip -O packer.zip
  unzip packer.zip
  sudo install packer /usr/local/bin/packer
  packer -autocomplete-install
  packer version
  rm ./packer.zip ./packer
}

install_virtualbox(){
  curl -fSsl https://www.virtualbox.org/download/oracle_vbox_2016.asc | apt-key add -
  curl -fSsl https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add -
  add-apt-repository 'deb http://download.virtualbox.org/virtualbox/debian bionic contrib'
  DEBIAN_FRONTEND=noninteractive sudo apt-get update
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y build-essential gcc make linux-headers-generic linux-headers-$(uname -r) dkms
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y virtualbox-${VBOX_VER}
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
  *)
    usage
    exit 1
    ;;
esac
