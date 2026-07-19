#!/usr/bin/env bash

get_step_description() {
    local step_id
    local descr
    local space=' '

    step_id=$1

    # descr="${step//"install_"}"
    # descr="${descr//"setup_"}"
    # descr="${descr//"start_"}"
    descr="${step_id//"_"/$space}"

    descr="$(tr '[:lower:]' '[:upper:]' <<< "${descr:0:1}")${descr:1}" # capitalize first letter
    echo "$descr"
}
