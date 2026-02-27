#!/usr/bin/env bash

function is_alive  {
    SERVICE=$1
    ALIVE=false

    SERVICE_NAME=$(echo "$SERVICE" | cut -d " " -f1)
    SERVICE_TYPE=$(echo "$SERVICE" | cut -d " " -f2)

    if [ "$SERVICE_TYPE" == "container" ]; then
        TEST=$(docker container ls --format '{{.Names}}' | grep "$SERVICE_NAME")
        if [ ! -z "$TEST" ]; then
                ALIVE=true
        fi
        $ALIVE
        return
    fi

    case "$SERVICE" in
        "web http_server" )
            TEST=$(lsof -i -P -n | grep LISTEN | grep 3000)
            if [ ! -z "$TEST" ]; then
                ALIVE=true
            fi
        ;;
        "docker" )
            TEST=$(docker stats --no-stream | grep CONTAINER)
            if [ ! -z "$TEST" ]; then
                ALIVE=true
            fi
        ;;
        \? )
            warn "Unknown service $SERVICE" 1>&2
            ;;

    esac
    $ALIVE
}
