#!/usr/bin/env bash
# shellcheck disable=SC1091

get_wsl_win_info() {

    ## what is this?
    # if [ -s "$WORKING_DIR/P1_USER_UNIX/names.sh" ]; then
    #     source "$WORKING_DIR/P1_USER_UNIX/names.sh"
    #     return
    # fi

    if [ -n "$P1_USER_WIN" ]; then 
        P1_USER_WIN=$(get_context 'p1_user_win'); 
        if [ -n "$P1_USER_WIN" ]; then
            P1_USER_WIN=$(cmd.exe /c "echo %USERNAME%" | tr -d '\r')
            set_context 'p1_user_win' "$P1_USER_WIN"
        fi
    fi

    if [ -n "$WINDOWS_HOME" ]; then 
        WINDOWS_HOME=$(get_context 'windows_home');
        if [ -n "$WINDOWS_HOME" ]; then
            WINDOWS_HOME=$(cmd.exe /c "echo %USERPROFILE%" | tr -d '\r')
            set_context 'windows_home' "$WINDOWS_HOME"
        fi
    fi

    if [ -n "$WORKING_DIR_WIN" ]; then 
        WORKING_DIR_WIN=$(get_context 'working_dir_win');
        if [ -n "$WORKING_DIR_WIN" ]; then
            WORKING_DIR_WIN=$(wslpath "$WINDOWS_HOME\\.pipeline1\\working")
            set_context 'working_dir_win' "$WORKING_DIR_WIN"
        fi
    fi

    if [ -n "$ONEDRIVE_HOME" ]; then 
        ONEDRIVE_HOME=$(get_context 'onedrive_home'); 
        if [ -n "$ONEDRIVE_HOME" ]; then
            ONEDRIVE_HOME=$(cmd.exe /c "echo %OneDrive%" | tr -d '\r')
            ONEDRIVE_HOME=$(wslpath "$ONEDRIVE_HOME")
            set_context 'onedrive_home' "$ONEDRIVE_HOME"
        fi
    fi
    if [ -n "$WORKING_DIR_ONEDRIVE" ]; then 
        WORKING_DIR_ONEDRIVE=$(get_context 'working_dir_onedrive');
        if [ -n "$WORKING_DIR_ONEDRIVE" ]; then
            # "$env:onedrive"
            WORKING_DIR_ONEDRIVE="$ONEDRIVE_HOME/Documents/working"
            set_context 'working_dir_onedrive' "$WORKING_DIR_ONEDRIVE"
        fi
    fi
}
