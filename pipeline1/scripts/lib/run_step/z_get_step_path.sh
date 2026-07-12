#!/usr/bin/env bash

get_step_path() {
    local step_registry
    local step_id
    local step_path=''

    step_registry="$WORKING_DIR/step_registry.csv"
    if [ ! -f "$step_registry" ]; then
        warn "Step registry file $step_registry not found"
        update_step_registry
    fi

    step_id="\"$1\""
    step_path=$(awk -F, -v id="$step_id" '$1 == id {print $4}' "$step_registry")
    step_path=${step_path//\"/}
    echo "$step_path"
}
