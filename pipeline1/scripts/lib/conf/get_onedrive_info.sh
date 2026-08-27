#!/usr/bin/env bash
# shellcheck disable=SC1091

get_onedrive_home() {
    if [ "$MY_OS" = 'macos' ]; then
        # ONEDRIVE_HOME=$(find "$HOME/Library/CloudStorage" -type d -name 'OneDrive' -print -quit)
        ONEDRIVE_HOME="$HOME/Library/CloudStorage/OneDrive-NHSDigital"
        return
    fi

    if [ "$VM" = 'wsl' ]; then
        ONEDRIVE_HOME=$(powershell.exe -Command '$env:OneDrive' | tr -d '\r')
        ONEDRIVE_HOME=$(wslpath "$ONEDRIVE_HOME")
        return
    fi

    warn "get_onedrive_home: Unable to determine OneDrive home directory for OS: $MY_OS, VM: $VM"
    ONEDRIVE_HOME=''
}

get_onedrive_info() {
    if [ -z "${ONEDRIVE_HOME+set}" ]; then 
        ONEDRIVE_HOME=$(get_context 'onedrive_home'); 
        if [ -z "$ONEDRIVE_HOME" ]; then
            get_onedrive_home
            set_context 'onedrive_home' "$ONEDRIVE_HOME"
        fi
    fi

    if [ -z "${WORKING_DIR_ONEDRIVE+set}" ]; then 
        WORKING_DIR_ONEDRIVE=$(get_context 'working_dir_onedrive');
        if [ -z "$WORKING_DIR_ONEDRIVE" ]; then
            WORKING_DIR_ONEDRIVE="$ONEDRIVE_HOME/Documents/working"
            set_context 'working_dir_onedrive' "$WORKING_DIR_ONEDRIVE"
        fi
    fi

}
