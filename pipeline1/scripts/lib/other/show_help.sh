#!/usr/bin/env bash

function show_help {
    local step
    local filename
    local file_path=''
    local event=""

    step=$1
    arg_len="$#"


    filename="$step.help.txt"
    if [ "$arg_len" -eq 2 ]; then 
        event=$2
        filename="$step.help.$event.txt"
    fi
    
    if [ ! -z ${CURRENT_PROJECT+empty_string} ]; then
        file_path=$(find "$P1_ROOT_UNIX/$CURRENT_PROJECT/steps" -name "$filename" -type f)
    fi
    if [ ! -f "$file_path" ]; then
        file_path=$(find "$P1_ROOT_UNIX/core/steps" -name "$filename" -type f)
        [ -f "$file_path" ] || return
    fi

    cat "$file_path"
    echo
    read -rp "Press any key to continue"
}
