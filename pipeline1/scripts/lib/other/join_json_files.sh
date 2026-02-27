#!/usr/bin/env bash

function join_json_files {
    local input_files
    local output_file
    local staging_file
    local header
    local footer
    # local file_type
    local index
    
    if [ -z ${1+empty_string} ];then
        warn "No json files to join"
        return
    fi

    # file_type=$1
    # shift
    input_files=( "$@" )

    staging_file="$WORKING_DIR/join_json_files_staging.json"
    sorted_file="$WORKING_DIR/join_json_files_sorted.json"
    # formatted_file="$WORKING_DIR/formatted.json"

    header='['
    footer=']'

    echo "$header" > "$staging_file"
    index=0
    for file in $input_files; do
        # app_id=$index

        file_dir=$(dirname "$file")
        app_dir=$(dirname "$file_dir")
        app_config_file=$(find "$app_dir" -name "config.json" -type f)
        [ ! -f "$app_config_file" ] && error "No config.json file found in $app_dir"
        # echo "app_config_file: $app_config_file"
        # cat "$app_config_file"
        app_id=$(jq -r '.id' "$app_config_file")
        # echo "app_id: $app_id"
        [ -z "$app_id" ] && error "No app id found in $app_config_file"

        enriched_file=$(jq -r ".+= {\"appId\":\"$app_id\"}" "$file")

        [ $index -ne 0 ] && echo "," >> "$staging_file"
        # cat "$file" >> "$staging_file"
        echo -n "$enriched_file" >> "$staging_file"
        index=$(( index + 1 ))
    done
    echo "$footer" >> "$staging_file"

    jq -r 'sort_by(.seq)' "$staging_file" > "$sorted_file"
    # sed -i '' 's/\ /~/g' "$sorted_file" > "$formatted_file"
    # rm "$staging_file"
    # rm "$sorted_file"
    # cat "$sorted_file"
}
