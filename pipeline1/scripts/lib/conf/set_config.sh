#!/usr/bin/env bash

set_config() {
    local key
    local value
    local group
    local current_value
    local args
    local status_file

    args=("$@")

    case $# in
    2)
        key=$1
        value=$2
        group='general'
        ;;
    3)
        key=$1
        value=$2
        group=$3
        ;;
    *)
        echo "Invalid number of arguments ($#) for set_config: ${args[*]}"
        return 1
        ;;
    esac

    current_value=$(get_config "$key" "$group")
    if [ "$current_value" = "$value" ]; then
        # debug "set_config: ${args[*]} unchanged from '$value'"
        return
    fi

    mkdir -p "$WORKING_DIR/dynamic_config/$group"
    
    status_file="$WORKING_DIR/dynamic_config/$group/$key.txt"
    # debug "=>set config"
    # debug "WORKING_DIR: $WORKING_DIR group: $group, key: $key, value: $value"
    # debug "status_file: $status_file"
    [ ! -f "$status_file" ] && touch "$status_file"
    echo "$value" > "$status_file"
}
