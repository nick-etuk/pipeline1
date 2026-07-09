#!/usr/bin/env bash

save_directories() {
    # Saves the current P1_ROOT_UNIX and REPO_DIR as configuration values.

    set_context p1_root_unix "$P1_ROOT_UNIX"
    REPO_DIR="$(dirname "$P1_ROOT_UNIX")"
    set_context repo_dir "$REPO_DIR" # todo: this is never read. Consider removing it.
}

set_repo_dir() {
    # Checks if P1_ROOT_UNIX has changed.
    # todo: Update login profiles if it has.
    
    local old_root_path
    
    old_root_path=$(get_context p1_root_unix)
    if [ -z "$old_root_path" ]; then
        save_directories
        return
    fi

    if [ "$old_root_path" != "$P1_ROOT_UNIX" ]; then
        warn "Pipeline1 root path has changed from $old_root_path to $P1_ROOT_UNIX"
        warn 'Please update P1_ROOT_UNIX in your login profile.'
        warn 'If the REPO_DIR has also changed, you will need to update that as well in your login profile.'
        save_directories
    fi
}
