#!/usr/bin/env bash

get_context() {
    local key
    local value
    local group
    local status_file

    case $# in
    1)
        key=$1
        group='global'
        ;;
    2)
        key=$1
        group=$2
        ;;
    *)
        # args=( "$@" )
        # error "Invalid number of arguments for get_context: ${args[*]}"
        echo "Invalid number of arguments for get_context"
        return 1
        ;;
    esac

    if [ ! -d "$WORKING_DIR/context/$group" ]; then
        warn "Context group '$group' undefined"
        return
    fi

    status_file="$WORKING_DIR/context/$group/$key.txt"
    if [ ! -f "$status_file" ]; then
        warn "Context variable '$key' undefined"
        return
    fi

    value=$(cat "$status_file")
    value=$(echo "$value" | xargs)
    echo "$value"
}
