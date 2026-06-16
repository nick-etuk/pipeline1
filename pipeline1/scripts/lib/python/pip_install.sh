#!/usr/bin/env bash

install_packages() {
	if ! dpkg --get-selections | grep -q python3-pip; then
		sudo apt-get -y install python3-pip
	fi
}


pip_install() {	
    if ! python3 -m pip list 2> /dev/null | grep -q pipeline1; then
        info "Installing Pipeline1 Python packages..."
        python3 -m pip install -r "$P1_ROOT_UNIX/requirements.txt"
        info "Installing Pipeline1 as an editable package at $P1_ROOT_UNIX..."
        python3 -m pip install -e "$P1_ROOT_UNIX"
    fi
}
