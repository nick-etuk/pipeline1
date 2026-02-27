#!/usr/bin/env bash

function check_service {
    local service

    service=${1+"${1}"}
    debug "=>check_service: $service"

    case "$service" in
        android|backendworker|bddtests|xamarinintegrationtests)
            check_docker_containers "$service"
            ;;
        http_server)
            check_http_server web
            ;;
        docker)
            check_docker_containers "$service"
            ;;
        *)
            error "Unknown service $service"
            return 1
            ;;
    esac

    return $?
}
