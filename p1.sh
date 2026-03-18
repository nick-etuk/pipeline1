#!/usr/bin/env bash
# shellcheck disable=SC1091,SC1090

# This is the primaary entry point before installation.
# Sets P1_ROOT_UNIX, then hands over to terminal_login.sh, 
# which will set up the environment and launch the main p1.py script.

current_dir=$(dirname "$(realpath "$0")")
cd "$current_dir" || exit


if [ -z "${P1_ROOT_UNIX+set}" ]; then
    echo 'Setting P1_ROOT_UNIX manually.'
    echo 'printenv | grep P1_ROOT_UNIX:'
    printenv | grep P1_ROOT_UNIX
    P1_ROOT_UNIX="$current_dir"
    P1_ROOT_SCRIPT="$P1_ROOT_UNIX/pipeline1/scripts"
    export P1_ROOT_UNIX
    export P1_ROOT_SCRIPT
fi

# init_script="$P1_ROOT_SCRIPT/init.sh" # Do we need to run init.sh here? Won't terminal_login do it?
# [ -z "${INIT_UNIX+set}" ] && source "$init_script"

script="$P1_ROOT_SCRIPT/edit_login_profile.sh"
if [ ! -f "$script" ]; then
    script=$(find "$P1_ROOT_SCRIPT" -name "edit_login_profile.sh")
    if [ -z "$script" ]; then
        echo "Warning: edit_login_profile.sh not found in $P1_ROOT_SCRIPT"
    fi
fi
[ -f "$script" ] && source "$script"

script="$P1_ROOT_SCRIPT/terminal_login.sh"
if [ ! -f "$script" ]; then
    script=$(find "$P1_ROOT_SCRIPT" -name "terminal_login.sh")
    if [ -z "$script" ]; then
        echo "Error: terminal_login.sh not found in $P1_ROOT_SCRIPT"
        exit 1
    fi
fi

source "$script"
