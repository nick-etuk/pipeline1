#!/usr/bin/env bash

invoke_commands() {
    local commands
    local exit_status

    if [ -z "${INIT_UNIX+set}" ]; then
        script_dir=$(dirname "$(realpath "$0")")
        cd "$script_dir" || exit
        . ./init.sh || exit 1
    fi

    commands=("$@")

    for command in ${commands[@]+"${commands[@]}"}; do
        eval "$command" >/dev/null
        exit_status=$?

        if [ "$exit_status" -ne 0 ]; then
            echo "bash command failed: $command"
            echo "status: $exit_status"
            return 1
        fi
        echo "bash command successful: $command"
    done

    return 0
}
invoke_commands "$@"
