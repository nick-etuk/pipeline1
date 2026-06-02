#!/usr/bin/env bash

activate_pyenv() {
    export PYENV_ROOT="$HOME/.pyenv"
    if [ ! -d $PYENV_ROOT/bin ]; then
		echo "Error: $PYENV_ROOT directory not found"
		exit 1
	fi
	
	if [[ ! $PATH == *.pyenv/bin* ]];then
		export PATH="$PYENV_ROOT/bin:$PATH"
	fi
	
	echo "Activating Pyenv for shell $SHELL_NAME"
    eval "$(pyenv init - $SHELL_NAME)"

    pyenv install "3.$PYTHON_MINOR_VERSION"
    pyenv global "3.$PYTHON_MINOR_VERSION"
	pip install --upgrade pip
}

install_pyenv(){
    local current_version
    local current_major
    local current_minor

    # Only install pyenv if Python 3.10 or above is not installed
    if command -v python3 >/dev/null; then
        current_version=$(python3 --version | awk '{print $2}')
        current_major=$(echo "$current_version" | cut -d. -f1)
        current_minor=$(echo "$current_version" | cut -d. -f2)

        if [ "$current_major" -eq $PYTHON_MAJOR_VERSION ] && [ "$current_minor" -eq $PYTHON_MINOR_VERSION ]; then
            echo "Python $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION installed and active."
            return
        fi
    fi

	echo "Installing Python $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION"
	echo "Current Python version: $current_version"
	echo "Current Python major version: [$current_major]"
	echo "Current Python major version: [$current_minor]"
	exit 1

    if [ command -v pyenv >/dev/null ]; then
		activate_pyenv
		return
	fi

    curl -fsSL https://pyenv.run | bash

	sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
		libbz2-dev libreadline-dev libsqlite3-dev \
		libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libzstd-dev

    # sudo apt-get -y install "python3.$PYTHON_MINOR_VERSION-venv" # This will be done by create_venv.sh

    activate_pyenv
}

