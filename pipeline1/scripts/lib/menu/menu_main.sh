#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2153

show_menu_extras() {
    printf "\tA Advanced \n"
    printf "\tH Help \n"
    printf "\tU Uninstall \n"
}

show_menu_main() {
    local project_registry
    local activity_registry
    local project_filename
    local project_id
    local project_title
    local activity_sort_order
    local activity_title
    local activity_project_id
    local activity_file
    local activity_id
    local project_path
    local option_num

    printf "\nWelcome to pipeline1\n\n"

    project_registry="$WORKING_DIR/project_registry_display_ordered.csv"
    if [ ! -f "$project_registry" ]; then
        warn "Project registry not found at $project_registry"
        return
    fi

    activity_registry="$WORKING_DIR/activity_registry.csv"
    if [ ! -f "$activity_registry" ]; then
        warn "Activity registry not found at $activity_registry"
        return
    fi

    while IFS=, read -r project_id project_sort_order project_display_order project_path project_title; do
        [ "$project_id" = '"project_id"' ] && continue  # Skip header line
        [ -z "$project_id" ] && continue  # Skip empty lines

        if [ -n "$project_title" ]; then
            # remove double quotes from project title
            project_title=${project_title//\"/}
            title_length=${#project_title}
            printf "\n\n\t"
            printf "%0.s-" $(seq 1 "$title_length")
            printf "\n\t%s\n" "$project_title"
            printf "\t"
            printf "%0.s-" $(seq 1 "$title_length")
            printf "\n"
        fi

        while IFS=, read -r activity_id activity_project_id activity_sort_order option_num activity_file activity_title; do
            if [ "$activity_project_id" != "$project_id" ]; then
                continue
            fi
            [ "$activity_id" = '"activity_id"' ] && continue  # Skip header line
            [ -z "$activity_id" ] && continue  # Skip empty lines
            activity_title=${activity_title//\"/}
            activity_id=${activity_id//\"/}
            printf "\t p1 %s \t %s \n" "$activity_id" "$activity_title"
        done < "$WORKING_DIR/activity_registry.csv"
    done < "$WORKING_DIR/project_registry_display_ordered.csv"

    printf "\n"
    show_menu_extras
    printf "\n"
}
