#!/usr/bin/env bash

show_config_base() {
    echo "MY_OS: $MY_OS"
    echo "VM: $VM"
    echo "SHELL_NAME: $SHELL_NAME"
    echo "SHELL_VERSION: $SHELL_VERSION"
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
    echo "ONEDRIVE_HOME: $ONEDRIVE_HOME"
    echo "WORKING_DIR_ONEDRIVE: $WORKING_DIR_ONEDRIVE"
}

show_config() {
    echo '--- P1 Shell Config ---'
    show_config_base
    show_config_unix
    if [ "$VM" = 'wsl' ];then # don't use a one-liner here. It will leave an error state.
		show_config_wsl
	fi
}
