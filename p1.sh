#!/usr/bin/env bash
# shellcheck disable=SC1091,SC1090

# This is the primaary entry point before installation.
# Sets P1_ROOT_UNIX, then hands over to terminal_login.sh, 
# which will set up the environment and launch the main p1.py script.

invoke_dir=$(pwd)
export P1_INVOKE_DIR="$invoke_dir"
script_dir=$(dirname "$(realpath "$0")")
cd "$script_dir" || exit


if [ -z "${P1_ROOT_UNIX+set}" ]; then
    echo "Setting P1 root directory manually to $script_dir"
    P1_ROOT_UNIX="$script_dir"
    P1_ROOT_SCRIPT="$P1_ROOT_UNIX/pipeline1/scripts"
    export P1_ROOT_UNIX
    export P1_ROOT_SCRIPT
fi

if [ -z "${P1_ROOT_SCRIPT+set}" ]; then
	P1_ROOT_SCRIPT="$P1_ROOT_UNIX/pipeline1/scripts"
	echo "Setting P1 script root manually to $P1_ROOT_SCRIPT"
	export P1_ROOT_SCRIPT
fi

# Check and to run init.sh here as terminal_login won't do it during fresh installations.
# [ -z "${INIT_UNIX+set}" ] && source "$P1_ROOT_SCRIPT/init.sh"

script="$P1_ROOT_SCRIPT/edit_login_profile.sh"
if [ ! -f "$script" ]; then
    script=$(find "$P1_ROOT_SCRIPT" -name "edit_login_profile.sh")
    if [ -z "$script" ]; then
        echo "Warning: edit_login_profile.sh not found in $P1_ROOT_SCRIPT"
    fi
fi

if [ -f "$script" ]; then
	source "$script"
	edit_login_profile
fi

# When P1 is invoke from the command line, clear the new_tab_queue
new_tab_queue_dir="$HOME/.pipeline1/working/new_tab_queue"
if [ -d "$new_tab_queue_dir" ]; then
    rm -rf "$new_tab_queue_dir"/*
fi

script="$P1_ROOT_SCRIPT/terminal_login.sh"
if [ ! -f "$script" ]; then
    script=$(find "$P1_ROOT_SCRIPT" -name "terminal_login.sh")
    if [ -z "$script" ]; then
        echo "Error: terminal_login.sh not found in $P1_ROOT_SCRIPT"
        exit 1
    fi
fi

source "$script" "$@"
