#!/usr/bin/env bash

function check_docker_images_v2 {

    image_setting_names=(WEB PFSAPI CIDAPI SJRCONFIG SJRAPI)

    missing_images=0
    for image in "${image_setting_names[@]}"; do
        registry_var="${image}_DOCKER_REGISTRY"
        registry=${!registry_var:-local};

        if [ "$registry" == "local" ]; then
            tag_var="${image}"_DOCKER_TAG
            tag=${!tag_var:-latest};

            if [ "$image" == "SJRCONFIG" ]; then
                image="service-journey-dev-config"
            elif [ "$image" == "SJRAPI" ]; then
                image="backendservicejourneyrulesapi"
            elif [ "$image" == "WEB" ]; then
                image="web"
            else
                image=$(echo "backend${image}" | tr '[:upper:]' '[:lower:]')
            fi;

            image_ref=$registry/nhsonline-${image}:$tag

            if [ -z "$(docker image ls -q --filter=reference="$image_ref")" ]; then
                error "missing image $image_ref"
                missing_images=$((missing_images+1))
            fi;
        fi;
    done;

    if [ $missing_images != 0 ]; then
        die "local images are missing, please run a build (make build)"
    fi;
}