#!/bin/bash
set -o nounset
set -o errexit

## Notes
# Use `sudo install tooling.sh /usr/local/bin`
# https://iridakos.com/tutorials/2018/03/01/bash-programmable-completion-tutorial.html

# Set source URLS
DM_BASE=https://github.com/docker/machine/releases/download/v0.16.0
DM_BASH=https://raw.githubusercontent.com/docker/machine/v0.16.0
DC_BASE=https://github.com/docker/compose/releases/download/1.23.1
DC_BASH=https://raw.githubusercontent.com/docker/compose/1.23.1/contrib/completion/bash
DK_BASH=https://raw.githubusercontent.com/docker/docker-ce

# Declare functions
set_docker_machine() {
  echo "INFO: Install docker-machine"
  curl -s -L $DM_BASE/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
  sudo install /tmp/docker-machine /usr/local/bin/docker-machine
  rm /tmp/docker-machine
  echo "INFO: Add bash completion for docker-machine"
  for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
  do
    sudo curl -s -L "$DM_BASH/contrib/completion/bash/${i}" -o /etc/bash_completion.d/${i}
  done

  echo "INFO: Alias docker-machine to dm"
  echo "alias dm='docker-machine'" >> $HOME/.bash_aliases
  echo "complete -F _docker_machine dm" >> $HOME/.bash_aliases

  echo "INFO: Install shell helpers to .bashrc"

  cat <<'EOF' >> $HOME/.bashrc

# Inidus shell additions
# Set docker environment vars using docker-machine env <node.name>
function dm-set() {
  eval "$(docker-machine env "${1:-default}")"
}
# Unset docker environment vars
function dm-unset() {
  eval "$(docker-machine env -u)"
}
# Set shell prompt based on docker-machine
PS1="$PS1$(__docker_machine_ps1)"
#PS1='[\u@\h \W$(__docker_machine_ps1)]\$ '

EOF
}

set_docker_compose() {
  echo "INFO: Install docker-compose"
  sudo curl -s -L $DC_BASE/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  echo "INFO: Add bash completion for docker-compose"
  sudo curl -s -L $DC_BASH/docker-compose -o /etc/bash_completion.d/docker-compose
  echo "alias dc='docker-compose'" >> $HOME/.bash_aliases
  echo "complete -F _docker_compose dc" >> $HOME/.bash_aliases
}

install_docker_engine() {
  # Docker - install
  DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y git apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  DEBIAN_FRONTEND=noninteractive sudo add-apt-repository 'deb https://download.docker.com/linux/ubuntu xenial stable'
  DEBIAN_FRONTEND=noninteractive sudo -E apt-get update
  DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y docker-ce
  sudo usermod -a -G docker $USER

  # Docker - Set logging to JSON
  sudo touch /etc/docker/daemon.json
  echo '{
    "log-driver": "json-file",
    "log-opts": {"max-size": "10m", "max-file": "3"}
}'|sudo tee -a /etc/docker/daemon.json

}

update_cgroup() {
  # Set cgroup_enable
  sudo sed -i '/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"' /etc/default/grub
  sudo update-grub
}

set_docker_engine() {
  echo "INFO: Add bash completion for docker engine"
  sudo curl -s -L $DK_BASH/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
  echo "alias dk='docker'" >> $HOME/.bash_aliases
  echo "complete -F _docker dk" >> $HOME/.bash_aliases
  echo "alias dk-ps='docker ps --format \"table {{.ID}}\t{{.Image}}\t{{.Status}}\"'" >> $HOME/.bash_aliases
}

disable_ipv6() {
  # Disable_ipv6
  echo 'net.ipv6.conf.all.disable_ipv6 = 1
  net.ipv6.conf.default.disable_ipv6 = 1
  net.ipv6.conf.lo.disable_ipv6 = 1'|sudo tee -a /etc/sysctl.conf
}

usage() {
  echo $"Usage: $0 {all|engine|compose|machine}"
  echo ""
  echo "Install docker tooling."
}

case "$1" in
  engine)
    install_docker_engine
    update_cgroup
    set_docker_engine
    disable_ipv6
    ;;
  machine)
    set_docker_machine
    ;;
  compose)
    set_docker_compose
    ;;
  all)
    install_docker_engine
    update_cgroup
    set_docker_engine
    disable_ipv6
    set_docker_machine
    set_docker_compose
    ;;
  *)
    usage
    exit 1
esac
