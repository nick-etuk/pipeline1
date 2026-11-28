#!/usr/bin/env bash

check_nvm() {
    NVM_VERSION=$(nvm -v)
    if [ -n "$NVM_VERSION" ]; then
        echo "nvm is installed. Version $NVM_VERSION"
    fi
}
