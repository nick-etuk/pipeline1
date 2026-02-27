# shellcheck shell=sh
# shellcheck disable=SC3054,SC1090,SC3030,SC1091,SC2012

# Initially, we will use the user's default shell, zsh.
# After setting the environment variables
# we will switch to bash for greater POSIX compatibility.

# Exit if running in an IDE terminal
[ -n "${INTELLIJ_ENVIRONMENT_READER+empty_string}" ] && return
[ "$TERM_PROGRAM" = 'vscode' ] && return

set -u
setopt shwordsplit

libraries=(
    get_shell_version 
    detect_os
    config_dynamic 
    add_to_path # must be called outside p1.sh
    add_aliases # must be called outside p1.sh
    config_base # source this last as it is a script, not a function
)
init_script=$(find "$P1_ROOT_UNIX" -name "init.sh" -type f -not -path '.venv_p1/*')
P1_ROOT_SCRIPT=$(dirname "$init_script")
export P1_ROOT_SCRIPT

for lib in "${libraries[@]}"; do
    script=$(find "$P1_ROOT_SCRIPT" -name "$lib.sh" -type f)
    . "$script"
done

get_shell_version
detect_os
echo "Terminal Shell is $SHELL_NAME version $SHELL_VERSION on $MY_OS"
add_to_path
add_aliases
# EDITOR="$(command -v nano || command -v vi || command -v vim || echo "/usr/bin/nano")"
# export EDITOR
# . "$P1_ROOT_UNIX/src/core/steps/environment/unix/add_to_path.sh"
# . "$P1_ROOT_UNIX/src/core/steps/environment/unix/add_aliases.sh"

new_tab_queue="$HOME/.pipeline1/working/new_tab_queue"
if [ -d "$new_tab_queue" ] && [ -n "$(ls "$new_tab_queue")" ]; then
    echo "Tasks found in New Tab queue..."

    cd "$P1_ROOT_SCRIPT" || return
    . ./init.sh

    oldest_file=$(ls -tr "$new_tab_queue" | head -n 1)
    if [ -f "$new_tab_queue/$oldest_file" ]; then
        process_new_tab_file "$new_tab_queue/$oldest_file"
    fi
    return
fi

# startup_script=$(find "$P1_ROOT_UNIX" -name 'p1.sh' -not -path '.venv_p1/*')
# No need to set startup_script again. Alread set in ~/.zshrc by edit_login_profile.sh
# startup_script="$P1_ROOT_UNIX/p1.sh"
[ -f "$startup_script" ]  || return

python3 "$startup_script"

default_step_path=$(get_config 'default_step_path')
if [ -n "$default_step_path" ] && [ -d "$default_step_path" ]; then
    cd "$default_step_path" || exit 1
fi

set +u

