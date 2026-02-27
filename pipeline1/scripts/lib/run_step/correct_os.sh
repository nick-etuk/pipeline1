#!/usr/bin/env bash

function correct_os {
    local step_os_array
    local step_os

    step_os_json=$1

    [ -z "$step_os_json" ] && return 0
    [ "$step_os_json" = 'null' ] && return 0

    step_os_array=($(echo "$step_os_json" | jq -r '.| .[]'))
    # debug "=> correct_os: ${step_os_array[*]}"

    for step_os in "${step_os_array[@]}"; do
        if [ "$step_os" = "$MY_OS" ] || [ "$step_os" = 'unix' ]; then
            return 0
        fi
    done
    return 1
}
