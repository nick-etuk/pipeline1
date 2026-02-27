#!/usr/bin/env bash

get_config() {
    local key
    local value
    local group
    local status_file

    case $# in
    1)
        key=$1
        group='general'
        ;;
    2)
        key=$1
        group=$2
        ;;
    *)
        # args=( "$@" )
        # error "Invalid number of arguments for get_config: ${args[*]}"
        echo "Invalid number of arguments for get_config"
        return 1
        ;;
    esac

    [ ! -d "$WORKING_DIR/dynamic_config/$group" ] && return

    status_file="$WORKING_DIR/dynamic_config/$group/$key.txt"
    [ ! -f "$status_file" ] && return

    value=$(cat "$status_file")
    echo "$value"
}
