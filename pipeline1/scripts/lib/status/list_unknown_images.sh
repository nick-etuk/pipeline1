#!/usr/bin/env bash

function list_unknown_images {
    local actual_images

    # actual_images=$(docker images --format "{{.Repository}}" | sort)
    actual_images=$(docker images --format "{{.Repository}}")
    # get docker images without the repository
    actual_images=$(echo "$actual_images" | awk -F'/' '{print $NF}' | sort)
    # for image in "${actual_images[@]}"; do
    for image in $actual_images; do
        # debug "Checking image [$image]"
        if [[ ! " ${EXPECTED_IMAGES[*]} " =~ [[:space:]]${image}[[:space:]] ]]; then
            warn "Unknown image $image"
        fi
        # if ! grep -q "$image" <<< "$EXPECTED_IMAGES"; then
        #     warn "Unknown image $image"
        # fi
    done
}
