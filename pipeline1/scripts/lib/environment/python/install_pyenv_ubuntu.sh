#!/usr/bin/env bash

install_pyenv_ubuntu() {
    curl -fsSL https://pyenv.run | bash

    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl git \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    
    sudo apt-get -y install python3.10-venv
}
