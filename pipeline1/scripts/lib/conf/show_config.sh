#!/usr/bin/env bash

show_config_base() {
    echo "MY_OS: $MY_OS"
    echo "BASE_DIR: $BASE_DIR"
    echo "WORKING_DIR: $WORKING_DIR"
    echo "LOG_DIR: $LOG_DIR"
    echo "REPO_DIR: $REPO_DIR"
    echo "DEBUG: $DEBUG"
    echo "FORCE: $FORCE"
    echo "DEFAULT_STEP_ID: $DEFAULT_STEP_ID"
    echo "DEFAULT_STEP_PATH: $DEFAULT_STEP_PATH"
    echo "NODE_MAJOR_VERSION: $NODE_MAJOR_VERSION"
}

show_config_unix() {
    echo "Shell: $SHELL_NAME version: $SHELL_VERSION"
    echo "P1_ROOT_UNIX: $P1_ROOT_UNIX"
    echo "CURRENT_USER: $P1_USER_UNIX"
}

show_config_wsl() {
    echo "P1_USER_WIN: $P1_USER_WIN"
    echo "WORKING_DIR_WIN: $WORKING_DIR_WIN"
}

show_config() {
    echo '--- P1 Shell Config ---'
    show_config_base
    show_config_unix
    [ "$VM" = 'wsl' ] && show_config_wsl
}
