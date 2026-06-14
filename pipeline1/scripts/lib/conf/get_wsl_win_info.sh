#!/usr/bin/env bash
# shellcheck disable=SC1091

get_wsl_win_info() {
    if [ -s "$WORKING_DIR/P1_USER_UNIX/names.sh" ]; then
        source "$WORKING_DIR/P1_USER_UNIX/names.sh"
        return
    fi

    P1_USER_WIN=$(get_config 'p1_user_win')
    if [ -n "$P1_USER_WIN" ]; then
        WORKING_DIR_WIN=$(get_config 'working_dir_win')
        WINDOWS_HOME=$(get_config 'windows_home')
        ONEDRIVE_HOME=$(get_config 'onedrive_home')
        WORKING_DIR_ONEDRIVE=$(get_config 'working_dir_onedrive')
        return
    fi

    ONEDRIVE_HOME=$(cmd.exe /c "echo %OneDrive%" | tr -d '\r')
    ONEDRIVE_HOME=$(wslpath "$ONEDRIVE_HOME")
    # "$env:onedrive"
    WORKING_DIR_ONEDRIVE="$ONEDRIVE_HOME/Documents/working"

    echo "No config entries found, using CMD.exe to capture P1_USER_WIN"
    P1_USER_WIN=$(cmd.exe /c "echo %USERNAME%" | tr -d '\r')
    WINDOWS_HOME=$(cmd.exe /c "echo %USERPROFILE%" | tr -d '\r')
    WORKING_DIR_WIN=$(wslpath "$WINDOWS_HOME\\.pipeline1\\working")
    [ -n "$P1_USER_WIN" ] && set_config 'p1_user_win' "$P1_USER_WIN"
    [ -n "$WORKING_DIR_WIN" ] && set_config 'working_dir_win' "$WORKING_DIR_WIN"
    [ -n "$WINDOWS_HOME" ] && set_config 'windows_home' "$WINDOWS_HOME"
    [ -n "$ONEDRIVE_HOME" ] && set_config 'onedrive_home' "$ONEDRIVE_HOME"
    [ -n "$WORKING_DIR_ONEDRIVE" ] && set_config 'working_dir_onedrive' "$WORKING_DIR_ONEDRIVE"
}
