#!/usr/bin/env bash

function install_homebrew {
    # Only needed for macos. For Ubuntu, we will use apt-get.
    [ "$MY_OS" = "macos" ] || return
    if command -v brew; then return; fi

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.bashrc
    # eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}
