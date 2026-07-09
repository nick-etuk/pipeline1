#!/usr/bin/env bash

function get_step_args {
    local input
    local step_args
    local stage_args

    input=$1
    step_args=()

    # split input by comma
    if [ "$SHELL_NAME" = 'zsh' ]; then
        error "Zsh is not supported for this function. Please use Bash."
    else
        IFS=',' read -ra step_args <<< "$input"
    fi
    for arg in "${step_args[@]}"; do
        debug "step arg: $arg"
        if [ "$arg" = '$@' ]; then
            debug "Adding stage args to step args"
            # shift step_args
            step_args=( "${step_args[@]:1}" )
            # add stage arguments to step arguments
            step_args=( "${stage_args[@]}" "${step_args[@]}" )
        fi
    done
    echo "${step_args[*]}"
}
