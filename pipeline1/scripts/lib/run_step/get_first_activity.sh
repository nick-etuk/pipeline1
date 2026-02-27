# shellcheck shell=sh
# shellcheck disable=SC2034,SC3054

get_first_activity() {
    [ -z "${1+empty_string}" ] && error "Project ID is required"

    project_id="$1"
    activity_registry="$WORKING_DIR/activity_registry.csv"
    matching_activity=$(awk -F, -v project_id="\"$project_id\"" '$2 == project_id { print $1 }' "$activity_registry" | head -n 1)
    if [ -z "$matching_activity" ]; then
        echo "No activities found for project $project_id"
        return
    fi
    # remove quotes if present, in a posix compliant way
    matching_activity=$(printf '%s\n' "$matching_activity" | sed 's/"//g')

    CURRENT_ACTIVITY="$matching_activity"
    set_config 'current_activity' "$CURRENT_ACTIVITY"
}