#!/usr/bin/env bash

install_py_packages() {
    local project_id
    local project_root
    local package_name
    
    project_id="$1"
    project_root=$(get_project_path "$project_id")

    if [ "$project_id" = "p1" ]; then
        package_name="pipeline1"
    else
        package_name="$project_id"
    fi

    if ! pip list | grep -q "$package_name"; then
        python -m pip install --upgrade pip
        info "Installing $package_name packages..."
        # pip install -r "$project_root/requirements.txt" # todo: fix this
        info "Installing $package_name as an editable package at $project_root..."
        pip install -e "$project_root"
    fi
}
