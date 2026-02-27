#!/usr/bin/env bash

function check_docker_containers {
    local service
    local expected_containers
    local base_containers
    local actual_containers
    local passed
    local calling_function
    local launch_mode

    arg_count=$#
    if [ "$arg_count" -eq 0 ]; then
        service='backendworker'
    else
        service=$1
    fi
    # service=${1+"backendworker"}
    debug "=>check_docker_containers service:>$service<"

    launch_mode=0
    calling_function=${FUNCNAME[2]}
    [ "$calling_function" = 'wait_for_service' ] && launch_mode=1

    [ $launch_mode -eq 0 ] && info "$service containers..."

    base_containers=(
        nhsapp-api.local.bitraft.io-1
        nhsapp-pfs.local.bitraft.io-1
        nhsapp-cid.local.bitraft.io-1
        nhsapp-servicejourneyrulesapi.local.bitraft.io-1
        nhsapp-silver.local.bitraft.io-1
        nhsapp-mongodb.bitraft.io-1
        nhsapp-web.local.bitraft.io-1
    )
    case $service in
    backendworker|backend_and_http|web)
        expected_containers=( "${base_containers[@]}" )
        ;;
    android)
        expected_containers=( "${base_containers[@]}" 'nhsapp-dns-1' )
        ;;
    bddtests)
        expected_containers=(
            int_test-api.local.bitraft.io-1
            int_test-cid.local.bitraft.io-1
            int_test-mongodb.bitraft.io-1
            int_test-pfs.local.bitraft.io-1
            int_test-servicejourneyrulesapi.local.bitraft.io-1
            int_test-silver.local.bitraft.io-1
            int_test-stubs.local.bitraft.io-1
            int_test-web.local.bitraft.io-1
        )
        ;;
    xamarinintegrationtests)
        expected_containers=(
            int_test-api.local.bitraft.io-1
            int_test-browserstack.local-1
            int_test-cid.local.bitraft.io-1
            int_test-dns-1
            int_test-mongodb.bitraft.io-1
            int_test-pfs.local.bitraft.io-1
            int_test-securestubs.local.bitraft.io-1
            int_test-servicejourneyrulesapi.local.bitraft.io-1
            int_test-silver.local.bitraft.io-1
            int_test-stubs.local.bitraft.io-1
        )
            # int_test-web.local.bitraft.io-1
        ;;
    *)
        error "check_docker_containers: unknown service $service"
    esac

    IFS=$'\n' sorted=($(sort <<<"${expected_containers[*]}"))
    
    actual_containers=$(docker container ls --format "{{.Names}}" | sort)
    calling_function=${FUNCNAME[1]}
    
    passed=0
    MISSING_CONTAINERS=()
    for item in "${sorted[@]}"; do
        if grep -q "$item" <<< "$actual_containers="; then
            [ "$launch_mode" -eq 0 ] && echo -e "$item $TICK_MARK"
        else
            passed=1
            MISSING_CONTAINERS+=("$item")
            [ "$launch_mode" -eq 0 ] && echo -e "$item $CROSS_MARK"
        fi
    done
    if [ "$service" = 'backend_and_http' ]; then
        [ "$passed" -eq 0 ] && passed=$(check_http_server backend_and_http)
    fi

    return "$passed"
}