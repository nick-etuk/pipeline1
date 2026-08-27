#!/usr/bin/env bash

activate_node() {
    local nvm_command
    local new_node_major_ver
    
    warn "Using nvm to activate Node $NODE_MAJOR_VERSION..."

    nvm_command="$HOME"/.nvm/nvm.sh
    if [ ! -d "$HOME/.nvm" ]; then
        error "NVM directory not found. Please install it and try again."
        return
    fi

    export NVM_DIR="$HOME"/.nvm
    if [ ! -f "$nvm_command" ]; then
        warn "nvm.sh not found in $NVM_DIR"
        return
    fi

    source "$nvm_command"
    nvm use "$NODE_MAJOR_VERSION"
    if [ $? -ne 0 ]; then
        warn "Failed to activate Node.js version $NODE_MAJOR_VERSION with NVM"
        return
    fi
    nvm alias default $NODE_MAJOR_VERSION

    new_node_major_ver=$(node -v | cut -d. -f1 | tr -d v)
    if [ "$new_node_major_ver" -lt "$NODE_MAJOR_VERSION" ]; then
        error "Could not activate Node $NODE_MAJOR_VERSION"
    fi
}
