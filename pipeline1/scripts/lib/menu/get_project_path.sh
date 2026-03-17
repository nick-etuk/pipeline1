#!/usr/bin/env bash

get_project_path() {
     local project_id

     project_id="$1"
    
    if [ "$project_id" = "p1" ]; then
        project_id="pipeline1"
        echo "$P1_ROOT"
        return
    fi

    project_registry="$WORKING_DIR/project_registry.csv"
    if [ ! -f "$project_registry" ]; then
        return
    fi

    todo: get p1_path from project registry
}