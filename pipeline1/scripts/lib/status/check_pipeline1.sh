#!/usr/bin/env bash

check_profile() {
    local profile_file
    profile_file="$1"

    [ ! -f "$profile_file" ] && return 1

    grep -iq 'pipeline1_v' "$profile_file" && return 0

    return 1
}

check_pipeline1() {
    check_profile "$HOME/.zshrc" && return 0
    check_profile "$HOME/.bashrc" && return 0
    return 1
}
