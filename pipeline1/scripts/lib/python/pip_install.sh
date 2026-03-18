#!/usr/bin/env bash

pip_install() {
    return
    if ! python3 -m pip list | grep -q pipeline1; then
        [ $MY_OS != 'macos' ] && python3 -m pip install --upgrade pip
        info "Installing Pipeline1 required packages..."
        python3 -m pip install -r "$P1_ROOT_UNIX/requirements.txt"
        info "Installing Pipeline1 as an editable package at $P1_ROOT_UNIX..."
        python3 -m pip install -e "$P1_ROOT_UNIX"
    fi
}
