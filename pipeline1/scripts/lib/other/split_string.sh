#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2207

split_string() {
    # Splits a string into an array using a delimiter
    # Arguments: string_to_split=$1 delimiter=$2 result_var=$3
    # Usage: split_string "a,b,c" "," result_array

    local string_to_split="$1"
    local delimiter="$2"
    SPLIT_STRING=()

    SPLIT_STRING=($(echo "$string_to_split" | awk "{gsub(\"$delimiter\",\" \"); print}"))
}