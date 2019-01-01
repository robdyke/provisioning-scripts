#!/bin/bash

set -o errexit

usage() {
  echo $"Usage: $0 {utils|node|ruby}"
  echo ""
}

install_utils() {
  sudo apt install -y htop iotop iftop nmap tmux git vim
}

install_node() {
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  sudo apt-get update
  sudo apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn
  node -v
  nodejs -v
}

install_rbenv() {
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  source $HOME/.bashrc
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
  source $HOME/.bashrc
  rbenv install 2.5.3
  rbenv global 2.5.3
  ruby -v
  gem -v
  gem install bundler
}


case "$1" in
  utils)
    install_utils
    ;;
  node)
    install_node
    ;;
  ruby)
    # install_node
    install_rbenv
    ;;
  *)
    usage
    exit 1
    ;;
esac
