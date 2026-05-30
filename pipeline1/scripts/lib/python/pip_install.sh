#!/usr/bin/env bash

install_pip_ubuntu() {
	if ! dpkg --get-selections | grep -q python3-pip; then
		sudo apt-get -y install python3-pip
	fi
	
	if ! dpkg --get-selections | grep -q python3-pip; then
		sudo apt-get install python3.14-venv
	fi
}

install_pip_macos() {
	return
}


pip_install() {
    install_pip_$MY_OS
	
    if ! python3 -m pip list | grep -q pipeline1; then
        info "Installing Pipeline1 Python packages..."
        python3 -m pip install -r "$P1_ROOT_UNIX/requirements.txt"
        info "Installing Pipeline1 as an editable package at $P1_ROOT_UNIX..."
        python3 -m pip install -e "$P1_ROOT_UNIX"
    fi
}
