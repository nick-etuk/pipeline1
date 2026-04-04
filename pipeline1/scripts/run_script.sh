#!/usr/bin/env bash
# shellcheck disable=SC1091

# Called by invoke_step.py
# Don't put this script into the lib directory because it is a script, not a function.

if [ -z "${INIT_UNIX+set}" ]; then
    script_dir=$(dirname "$(realpath "$0")")
    cd "$script_dir" || exit
    . ./init.sh || exit 1
fi

step_script=$1
shift
step_args=("$@")

source "$step_script" "${step_args[*]+"${step_args[*]}"}"

default_step_path=$(get_config 'default_step_path')
if [ -n "$default_step_path" ] && [ -d "$default_step_path" ]; then
    cd "$default_step_path" || exit 1
fi

set +u