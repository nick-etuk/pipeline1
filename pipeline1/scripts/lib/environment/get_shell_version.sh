#!/usr/bin/env bash

get_shell_version() {
    if [ -n "${BASH_VERSION+empty_string}" ]; then
        SHELL_NAME='bash'
        SHELL_VERSION=$(echo "$BASH_VERSION" | sed -E 's/.*version ([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
        return
    fi
    if [ -n "${ZSH_VERSION+empty_string}" ]; then
        SHELL_NAME='zsh'
        SHELL_VERSION="$ZSH_VERSION"
        return
    fi
    SHELL_NAME='unknown'
    SHELL_VERSION='unknown'
}
