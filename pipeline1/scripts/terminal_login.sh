# shellcheck shell=sh
# shellcheck disable=SC3054,SC1090,SC3030,SC1091,SC2012

# Initially, we will use the user's default shell, zsh.

# Exit if running in an IDE terminal
[ -n "${INTELLIJ_ENVIRONMENT_READER+empty_string}" ] && return
[ "$TERM_PROGRAM" = 'vscode' ] && return

set -u

required_libraries=(
    logging
    get_shell_version 
    detect_os
    get_wsl_win_info
    config_ubuntu
    config_macos
    config_dynamic
    add_to_path
    add_aliases
    check_for_os_updates
    daily_tasks
    split_string
    process_new_tab_file
	install_pyenv
    create_venv
    pip_install
    get_context
    edit_login_profile
    config_base # source this last as it is a script, not a function
)
for lib in "${required_libraries[@]}"; do
    script=$(find "$P1_ROOT_SCRIPT/lib" -name "$lib.sh" -type f)
    . "$script"
done

get_shell_version
detect_os

if [ "$MY_OS" != 'macos' ]; then
    script=$(find "$P1_ROOT_SCRIPT" -name 'add_to_sudoers.sh' -type f)
    sudo "$script" "$MY_OS"
fi

add_to_path
add_aliases
edit_login_profile
daily_tasks
new_tab_queue="$HOME/.pipeline1/working/new_tab_queue"
if [ -d "$new_tab_queue" ] && [ -n "$(ls "$new_tab_queue")" ]; then
    echo "Tasks found in New Tab queue..."

    cd "$P1_ROOT_SCRIPT" || return
    . ./init.sh

    oldest_file="$(ls -tr "$new_tab_queue" | head -n 1)"
    echo "Oldest file in new tab queue: $oldest_file"
    if [ -f "$new_tab_queue/$oldest_file" ]; then
        process_new_tab_file "$new_tab_queue/$oldest_file"
    fi
else
	if ! install_pyenv; then
		read -r  "Warning error installing Python $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION via Pyenv. Continue (y/n)? " prompt
		[ ! "$prompt" = "y" ] && exit 1
	fi
	
    if ! create_venv; then
		echo 'Error creating Python virtual environment' 
		exit 1
	fi
	
    if ! pip_install; then
		echo 'Error installing Python packages'
		exit 1
	fi
    python3 "$P1_ROOT_UNIX/pipeline1/p1.py" "$@"
fi

default_step_path=$(get_context 'default_step_path')
if [ -n "$default_step_path" ] && [ -d "$default_step_path" ]; then
    cd "$default_step_path" || exit 1
fi

set +u
