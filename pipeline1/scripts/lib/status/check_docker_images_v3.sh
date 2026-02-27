#!/usr/bin/env bash
function get_internal_images {
    local modules
    local module
    local image

    modules=(WEB PFSAPI CIDAPI SJRCONFIG SJRAPI)

    for module in "${modules[@]}"; do
        case "$module" in
            SJRCONFIG)
                image="service-journey-dev-config"
            ;;
            SJRAPI)
                image="backendservicejourneyrulesapi"
                ;;
            WEB)
                image="web"
                ;;
            *)
                image=$(echo "backend${module}" | tr '[:upper:]' '[:lower:]')
                ;;
            esac
            INTERNAL_IMAGES+=("nhsonline-${image}")
    done;
}


function get_expected_images {
    EXTERNAL_IMAGES=(
        backend-build
        mongo
        nginx
        nginx-unprivileged
        socat
        wiremock
    )

    INTERNAL_IMAGES=()
    get_internal_images

    all_images=( 
        ${EXTERNAL_IMAGES[@]}
        ${INTERNAL_IMAGES[@]}
    )
    IFS=$'\n' EXPECTED_IMAGES=($(sort <<<"${all_images[*]}"))
}

function check_docker_images_v3 {
    local service
    # local missing_images
    local actual_images
    local calling_function
    local launch_mode

    service=$1

    get_expected_images
    case "$service" in
        android)
            EXTERNAL_IMAGES+=(
                dnsmasq
            )
            # pull access denied for local/nhsonline-web-init, repository does not exist 
            # or may require 'docker login': denied: requested access to the resource is denied
            # Unknown image nhsonline-aspdotnetcore-runtime
            # Unknown image nhsonline-aspdotnetcore-runtime
            # Unknown image nhsonline-aspdotnetcore-runtime
            # Unknown image nhsonline-aspdotnetcore-runtime
            # Unknown image nhsonline-backendcdsswiremock
            # Unknown image nhsonline-browserstack-local
            # Unknown image nhsonline-dotnetcore-build
            # Unknown image nhsonline-dotnetcore-build
            # Unknown image nhsonline-dotnetcore-build
            # Unknown image nhsonline-int-tests-dotnet-build
            # Unknown image nhsonline-nodejs-build
            # Unknown image nhsonline-nodejs-build
            ;;
        *)
    esac

    # Launch mode is used to reduce the amount of messages shown to the user
    # Progress messages are shown when the backend services are being built or started

    launch_mode=0
    calling_function=${FUNCNAME[2]}
    [ "$calling_function" = "wait_for_service" ] && launch_mode=1
    [ "$launch_mode" = 0 ] && info "$service images..."
 
    MISSING_IMAGES=()
    actual_images=$(docker images --format "{{.Repository}}")
    actual_images=$(echo "$actual_images" | awk -F'/' '{print $NF}' | sort)

    passed=0
    debug "Expected images: >${EXPECTED_IMAGES[*]}<"
    debug "Actual images: >${actual_images[*]}<"
    for image in "${EXPECTED_IMAGES[@]}"; do
    # for image in $EXPECTED_IMAGES; do
        if [[ ! " ${actual_images[*]} " =~ [[:space:]]${image}[[:space:]] ]]; then
            warn "Missing docker image $image"
            passed=1
            [ "$launch_mode" = 0 ] && echo -e "${RED}$image $CROSS_MARK ${NC}"
            MISSING_IMAGES+=("$image")
        else
            [ "$launch_mode" = 0 ] && echo -e "${GREEN}$image $TICK_MARK ${NC}"
        fi
        # if ! grep -q "$image" <<< "$actual_images"; then
        #     passed=1
        #     $launch_mode && echo -e "${RED}$image $CROSS_MARK ${NC}"
        # else
        #     $launch_mode && echo -e "${GREEN}$image $TICK_MARK ${NC}"
        # fi
    done
    return $passed
}
