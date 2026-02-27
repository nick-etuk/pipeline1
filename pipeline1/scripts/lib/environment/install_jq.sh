#!/usr/bin/env bash

function install_jq_ubuntu {
    install_jq_linux
}

function install_jq_macos {
    ! command -v brew >/dev/null && install_homebrew
    brew install jq
}

function install_jq_linux {
    sudo apt-get -y install jq
}

function install_jq {
    if command -v jq; then return; fi

    install_jq_"$MY_OS"
}