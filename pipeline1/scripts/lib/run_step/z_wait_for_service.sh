#!/usr/bin/env bash

function wait_for_service {
    local service_type
    local service
    local pause
    local max_wait

    pause=10

    service_type=$1
    service=$2
    max_wait="${3:-300}"

    WAIT_FOR_SERVICE_STATUS=0
    check_service "$service_type" "$service"
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        WAITED=$((WAITED+pause))
        if [ "$WAITED" -gt "$max_wait" ]; then
            echo ''
            echo -e "${YELLOW}$service $service_type not started after $max_wait seconds. Please start them manually. ${NC}"
            WAIT_FOR_SERVICE_STATUS=1
            return 1
        fi 
        echo -n "."
        sleep $pause
        wait_for_service "$service_type" "$service" "$max_wait"
    fi
    echo ''
}
