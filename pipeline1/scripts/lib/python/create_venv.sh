#!/usr/bin/env bash

install_packages() {
	if ! dpkg --get-selections | grep -q python3-pip; then
		sudo apt-get install "python3.$PYTHON_MINOR_VERSION-venv"
	fi
}

create_venv() {
    venv_dir="$P1_ROOT_UNIX/.venv_p1"
	
	[ $MY_OS = 'ubuntu' ] && install_packages
	
    if [ ! -d "$venv_dir" ]; then
        # prompt before creating venv
        read -rp "Creating Python virtual environment. Proceed? (y/n) " create_venv
        if [ "$create_venv" = "y" ]; then
            echo 'Creating Python virtual environment .venv_p1'
            venv_dir="$P1_ROOT_UNIX/.venv_p1"
            python3 -m venv "$venv_dir"
        else
            echo 'Aborting.'
            exit 1
        fi
    fi

    if [ -z "${VIRTUAL_ENV+set}" ]; then
        echo 'Activating virtual environment...'
        venv_activate="$P1_ROOT_UNIX/.venv_p1/bin/activate"
        [ -f "$venv_activate" ] && source "$venv_activate"
    fi
}
