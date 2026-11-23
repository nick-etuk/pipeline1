#!/usr/bin/env bash

check_invalid_directory() {
    echo "Directory $1 does not exist"
    return 1
    # info ""

    # read -rp "Repo path currently set to $REPO_DIR. Is this correct?" option
    # if [ ! "$option" = 'n' ]; then
    #     error "Could not switch to directory $1"
    #     exit 1
    # fi

    # read -rp 'Please enter the correct repo path: ' REPO_DIR
    # set_context repo_dir "$REPO_DIR"
    # info 'Please re-run nshapp.sh to try again'
    # exit 1
}

switch_to() {
    [ $# -eq 0 ] && { echo "No directory specified to switch to"; return 1; }
    [ $# -gt 1 ] && { echo "Too many arguments for switch_to: $*"; return 1; }

    [ "$1" = "$(pwd)" ] && return

    [ -d "$1" ] || check_invalid_directory "$1"

    cd "$1" || { echo "Error: Could not switch to $1"; return 1; }
}

switch_back() {
    switch_to "$P1_ROOT_UNIX"
}
