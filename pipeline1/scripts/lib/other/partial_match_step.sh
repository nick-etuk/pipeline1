#!/usr/bin/env bash

partial_match_step() {
    local step_name="$1"
    local step_script
    local script_dir

    # Find the step script based on partial match of the provided name
    # Search current project first
    # Secondly, search other projects
    # Thirdly, search core steps
    # Never search core/lib
    step_script=$(find "$P1_ROOT_SCRIPT/steps" -name "*${step_name}*.sh" -type f | head -n 1)
    
    if [ -z "$step_script" ]; then
        echo "No step script found for '$step_name'."
        return 1
    fi

    # Get the directory of the step script
    script_dir=$(dirname "$step_script")

    # Source the step script to run it
    source "$step_script"
}