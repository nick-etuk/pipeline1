#!/usr/bin/env bash

function get_next_run_id {
    local last_run_id
    local directories

    if [ "$DEBUG" -eq 1 ] || [ ! -d "$LOG_BASE" ]; then
        RUN_ID='001'
        return
    fi

    switch_to "$LOG_BASE"
    directories=$(ls -d */ | cut -f1 -d'/')
    switch_back

    # debug "directories1: $directories"
    # debug "directories *: ${directories[*]}"
    # debug "directories @:" 
    # len="${#directories[@]}"
    # debug "len: $len"
    # last_element="${directories[$len-1]}"
    # debug "last_element: $last_element"
    # last_run_id="${directories[${#directories[@]}-1]}"

    # for directory in "${directories[@]}";do
    for directory in $directories;do
        last_run_id="$directory"
    done
    RUN_ID=$(( $last_run_id + 1 ))
    printf -v RUN_ID "%03d" $RUN_ID
}
