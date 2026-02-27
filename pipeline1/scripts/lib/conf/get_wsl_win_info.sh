#!/usr/bin/env bash
# shellcheck disable=SC1091

get_wsl_win_info() {
    if [ -s "$WORKING_DIR/P1_USER_UNIXnames.sh" ]; then
        source "$WORKING_DIR/P1_USER_UNIXnames.sh"
        return
    fi

    P1_USER_WIN=$(get_config 'p1_user_win')
    if [ -n "$P1_USER_WIN" ]; then
        WORKING_DIR_WIN=$(get_config 'working_dir_win')
        WINDOP1_HOME=$(get_config 'windop1_home')
        return
    fi

    echo "No config entries found, using CMD.exe to capture P1_USER_WIN"
    P1_USER_WIN=$(cmd.exe /c "echo %USERNAME%" | tr -d '\r')
    WINDOP1_HOME=$(cmd.exe /c "echo %USERPROFILE%" | tr -d '\r')
    WORKING_DIR_WIN=$(wslpath "$WINDOP1_HOME\\.pipeline1\\working")
    [ -n "$P1_USER_WIN" ] && set_config 'p1_user_win' "$P1_USER_WIN"
    [ -n "$WORKING_DIR_WIN" ] && set_config 'working_dir_win' "$WORKING_DIR_WIN"
    [ -n "$WINDOP1_HOME" ] && set_config 'windop1_home' "$WINDOP1_HOME"
}
