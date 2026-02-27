#!/usr/bin/env bash

function check_docker_images_v1 {
    local service
    local expected_images
    local actual_images
    local passed
    local calling_function
    local launch_mode

    service=$1

    base_images=(
        nhsonline-web
        nhsonline-web-build
        nhsonline-web-init
        nhsonline-web-lint
        nhsonline-web-build-dependencies
        nhsonline-web-production-dependencies
        nhsonline-dotnetcore-build
        nhsonline-nodejs-build
        nhsonline-aspdotnetcore-runtime
        nginx-unprivileged
        # images below are possibly for web
        nhsonline-service-journey-dev-config
        nhsonline-backendservicejourneyrulesapi
        nhsonline-backendcidapi
        nhsonline-backendpfsapi
        # local/nhsonline-dev-stubs
        # local/nhsonline-backendcdsswiremock
        # local/backend-build
        # alpine/socat
        # mongo
        # nginx
        # wiremock/wiremock
        # nhsapp.azurecr.io/nhsonline-int-tests-base
        # "nhsapp.azurecr.io/wiremock"
    )

    # expected_images_NO_TAGS=$(echo $expected_images_NO_TAGS | sort)
    # echo "Checking docker images for $1"

    case $service in
        backendworker)
            expected_images=("${base_images[@]}")
            ;;
        bddtests)
            expected_images=("${base_images[@]}")
            ;;
        xamarin)
            expected_images+=(
                "nhsapp.azurecr.io/nhsonline-aspdotnetcore-runtime"
            )
            ;;
        xamarinintegrationtests)
            expected_images+=(
                local/nhsonline-http-mocks
                local/nhsonline-integration-tests
                local/nhsonline-service-journey-integration-test-config
                nhsapp.azurecr.io/nhsonline-int-tests-dotnet-build
            )
            ;;
        web)
            expected_images+=(
                "local/nhsonline-web"
            )
            ;;
        android)
            expected_images=(
                "alpine/socat"
                "andyshinn/dnsmasq"
                "local/backend-build"
                "local/nhsonline-backendcdsswiremock"
                "local/nhsonline-backendcidapi"
                "local/nhsonline-backendpfsapi"
                "local/nhsonline-backendservicejourneyrulesapi"
                "local/nhsonline-service-journey-dev-config"
                "local/nhsonline-web"
                "local/nhsonline-web-build"
                "local/nhsonline-web-build-dependencies"
                "local/nhsonline-web-lint"
                "local/nhsonline-web-production-dependencies"
                "mongo"
                "nginx"
                "nhsapp.azurecr.io/nginx-unprivileged"
                "nhsapp.azurecr.io/nhsonline-aspdotnetcore-runtime"
                "nhsapp.azurecr.io/nhsonline-dotnetcore-build"
                "nhsapp.azurecr.io/nhsonline-nodejs-build"
                "nhsapp.azurecr.io/wiremock"
                "wiremock/wiremock"
            )
            ;;
        *)
            error "check_images_v1: unknown service $service"
            ;;
    esac

    IFS=$'\n' sorted_expected_images=($(sort <<<"${expected_images[*]}"))
    # actual_images=$(docker images --format "{{.Repository}}" | sort)

    launch_mode=0
    calling_function=${FUNCNAME[2]}
    [ "$calling_function" = "wait_for_service" ] && launch_mode=1
    [ "$launch_mode" = 0 ] && info "$service images..."
 
    MISSING_IMAGES=()
    actual_images=$(docker images --format "{{.Repository}}")
    actual_images=$(echo "$actual_images" | awk -F'/' '{print $NF}' | sort)
    debug "expected_images: >${sorted_expected_images[*]}<"
    debug "actual_images: >$actual_images<"

    passed=0
    for image in "${sorted_expected_images[@]}"; do
        # if ! grep -q "$image" <<< "$actual_images"; then
        debug "image: >$image<"
        if [[ ! " ${actual_images[*]} " =~ [[:space:]]${image}[[:space:]] ]]; then
            passed=1
            [ "$launch_mode" -eq 0 ] && echo -e "${RED}$image ${NC}$CROSS_MARK"
            MISSING_IMAGES+=("$image")
        else
            [ "$launch_mode" -eq 0 ] && echo -e "${GREEN}$image $TICK_MARK ${NC}"
        fi
    done

    return $passed
}
