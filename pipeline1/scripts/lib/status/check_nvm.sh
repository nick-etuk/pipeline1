#!/usr/bin/env bash

function check_nvm {
    NVM_VERSION=$(nvm -v)
    if [ -n "$NVM_VERSION" ]; then
        echo "nvm is installed. Version $NVM_VERSION"
    fi
}
