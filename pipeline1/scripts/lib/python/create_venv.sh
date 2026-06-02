#!/usr/bin/env bash

install_packages() {
	if ! dpkg --get-selections | grep -q python3-venv; then
		# sudo apt-get install "python3.$PYTHON_MINOR_VERSION-venv"
		sudo apt-get install "python3-venv"
	fi
}

create_venv() {
	echo '=>create_venv'
	local venv_dir
	
	# [ $MY_OS = 'ubuntu' ] && install_packages 	# This should be bone by Pyenv

    venv_dir="$P1_ROOT_UNIX/.venv_p1"
	
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
