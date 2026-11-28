#!/usr/bin/env bash
# shellcheck disable=SC1091,SC1090

# This is the primaary entry point before installation.
# Sets P1_ROOT_UNIX, then hands over to terminal_login.sh, 
# which will set up the environment and launch the main p1.py script.

required_libraries=(
    get_context
    set_context
    get_shell_version
    detect_os
    get_onedrive_info
    get_wsl_win_info
    check_pipeline1
    config_ubuntu
    config_macos
    config_base # source this last as it is a script, not a function
)

for lib in "${required_libraries[@]}"; do
    script=$(find "$P1_ROOT_SCRIPT/lib" -name "$lib.sh" -type f)
    . "$script"
done


# This is used in add_project.py
invoke_dir=$(pwd)
set_context 'p1_invoke_dir' "$invoke_dir"
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


# When P1 is invoked from the command line, clear the new_tab_queue
new_tab_queue_dir="$HOME/.pipeline1/working/new_tab_queue"
if [ -d "$new_tab_queue_dir" ]; then
    rm -rf "$new_tab_queue_dir"/*
fi

# if .zshrc or .bashrc contain 'pipeline1 start', turn off bootstrap mode.
# Maybe change the alias of p1 to run python p1.py instead of p1.sh - is this necessary? We can just lauch p1.py here.
# .zshrc must always run terminal_login.sh
# Launch p1.py here.

if check_pipeline1; then
    python3 "$P1_ROOT_UNIX/pipeline1/p1.py" "$@"
    exit 0
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

script="$P1_ROOT_SCRIPT/terminal_login.sh"
if [ ! -f "$script" ]; then
    script=$(find "$P1_ROOT_SCRIPT" -name "terminal_login.sh")
    if [ -z "$script" ]; then
        echo "Error: terminal_login.sh not found in $P1_ROOT_SCRIPT"
        exit 1
    fi
fi
source "$script" "$@"
