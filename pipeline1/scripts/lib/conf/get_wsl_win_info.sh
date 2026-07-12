#!/usr/bin/env bash
# shellcheck disable=SC1091

get_wsl_win_info() {
    if [ -z "${P1_USER_WIN+set}" ]; then 
        P1_USER_WIN=$(get_context 'p1_user_win'); 
        if [ -z "$P1_USER_WIN" ]; then
            P1_USER_WIN=$(powershell.exe -Command '$env:USERNAME' | tr -d '\r')
            set_context 'p1_user_win' "$P1_USER_WIN"
        fi
    fi

    if [ -z "${WINDOWS_HOME+set}" ]; then 
        WINDOWS_HOME=$(get_context 'windows_home');
        if [ -z "$WINDOWS_HOME" ]; then
            WINDOWS_HOME=$(powershell.exe -Command '$env:USERPROFILE' | tr -d '\r')
            WINDOWS_HOME=$(wslpath "$WINDOWS_HOME")
            set_context 'windows_home' "$WINDOWS_HOME"
        fi
    fi

    if [ -z "${GIT_PATH_WIN+set}" ]; then 
        GIT_PATH_WIN=$(get_context 'git_path_win');
        if [ -z "$GIT_PATH_WIN" ]; then
            exe_path=$(powershell.exe -Command '(Get-Command git).path' | tr -d '\r')
            exe_path=$(wslpath "$exe_path")
            grand_parent_dir=$(dirname "$(dirname "$exe_path")")
            GIT_PATH_WIN="$grand_parent_dir"
            set_context 'git_path_win' "$GIT_PATH_WIN"
        fi
    fi

    if [ -z "${WORKING_DIR_WIN+set}" ]; then 
        WORKING_DIR_WIN=$(get_context 'working_dir_win');
        if [ -z "$WORKING_DIR_WIN" ]; then
            WORKING_DIR_WIN="$WINDOWS_HOME/.pipeline1/working"
            set_context 'working_dir_win' "$WORKING_DIR_WIN"
        fi
    fi

    if [ -z "${ONEDRIVE_HOME+set}" ]; then 
        ONEDRIVE_HOME=$(get_context 'onedrive_home'); 
        if [ -z "$ONEDRIVE_HOME" ]; then
            ONEDRIVE_HOME=$(powershell.exe -Command '$env:OneDrive' | tr -d '\r')
            ONEDRIVE_HOME=$(wslpath "$ONEDRIVE_HOME")
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
    if [ -z "${COMPUTER_NAME_WIN+set}" ]; then 
        COMPUTER_NAME_WIN=$(get_context 'computer_name_win');
        if [ -z "$COMPUTER_NAME_WIN" ]; then
            COMPUTER_NAME_WIN=$(powershell.exe -Command '$env:COMPUTERNAME' | tr -d '\r')
            set_context 'computer_name_win' "$COMPUTER_NAME_WIN"
        fi
    fi
    if [ -z "${WINDOWS_APP_INSTALL_DIR+set}" ]; then 
        WINDOWS_APP_INSTALL_DIR=$(get_context 'windows_app_install_dir');
        if [ -z "$WINDOWS_APP_INSTALL_DIR" ]; then
            if [ "$COMPUTER_NAME_WIN" = 'DESKTOP-2022' ]; then
                WINDOWS_APP_INSTALL_DIR="/mnt/f/app"
            else
                WINDOWS_APP_INSTALL_DIR="/mnt/c/Program Files"
            fi
            set_context 'windows_app_install_dir' "$WINDOWS_APP_INSTALL_DIR"
        fi
    fi
}
