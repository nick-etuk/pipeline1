#!/usr/bin/env bash

source "$P1_ROOT_SCRIPT/lib/environment/python/install_pyenv_ubuntu.sh"
# source "$P1_ROOT_SCRIPT/lib/environment/python/install_pyenv_macos.sh"

install_pyenv(){
    local python_version
    local python_major
    local python_minor

    # Only install pyenv if Python 3.10 or above is not installed
    if command -v python3 >/dev/null; then
        python_version=$(python3 --version | awk '{print $2}')
        python_major=$(echo "$python_version" | cut -d. -f1)
        python_minor=$(echo "$python_version" | cut -d. -f2)

        if [ "$python_major" -gt 3 ] || { [ "$python_major" -eq 3 ] && [ "$python_minor" -ge 10 ]; }; then
            # echo "Python $python_version is already installed. Skipping pyenv installation."
            return
        fi
    fi

    command -v pyenv >/dev/null && return

    install_pyenv_"${MY_OS}"

    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init - zsh)"

    pyenv install 3.10
    pyenv global 3.10
}
install_pyenv