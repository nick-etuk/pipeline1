#!/usr/bin/env bash

show_config_base() {
    debug "MY_OS: $MY_OS"
    debug "VM: $VM"
    debug "SHELL_NAME: $SHELL_NAME"
    debug "SHELL_VERSION: $SHELL_VERSION"
    debug "BASE_DIR: $BASE_DIR"
    debug "WORKING_DIR: $WORKING_DIR"
    debug "LOG_DIR: $LOG_DIR"
    debug "REPO_DIR: $REPO_DIR"
    debug "DEBUG: $DEBUG"
    debug "FORCE: $FORCE"
    # debug "DEFAULT_STEP_ID: $DEFAULT_STEP_ID"
    # debug "DEFAULT_STEP_PATH: $DEFAULT_STEP_PATH"
    debug "NODE_MAJOR_VERSION: $NODE_MAJOR_VERSION"
}

show_config_unix() {
    debug "Shell: $SHELL_NAME version: $SHELL_VERSION"
    debug "P1_ROOT_UNIX: $P1_ROOT_UNIX"
    debug "CURRENT_USER: $P1_USER_UNIX"
}

show_config_wsl() {
    debug "P1_USER_WIN: $P1_USER_WIN"
    debug "WORKING_DIR_WIN: $WORKING_DIR_WIN"
    debug "ONEDRIVE_HOME: $ONEDRIVE_HOME"
    debug "WORKING_DIR_ONEDRIVE: $WORKING_DIR_ONEDRIVE"
}

show_config() {
    debug '--- P1 Shell Config ---'
    show_config_base
    show_config_unix
    if [ "$VM" = 'wsl' ];then # don't use a one-liner here. It will leave an error state.
		show_config_wsl
	fi
}
