#!/usr/bin/env bash

check_for_os_updates() {
    local last_update
    local flag
    
    [ -z "${MY_OS+empty_string}" ] && return

    [ "$MY_OS" != "ubuntu" ] && return

    # Only update packages once per day
    flag="$WORKING_DIR/os_last_update.txt"
    if [ -f "$flag" ] && [ -s "$flag" ]; then
        last_update=$(cat "$flag")
        if [ "$(date -d "$last_update" +%s)" -ge "$(date +%s --date '1 day ago')" ]; then
            echo "OS packages recently updated on $(date -d "$last_update" +'%A %d %B %Y at %H:%M')"
            return
        fi
    fi
    echo 'Updating OS packages...'
    sudo apt-get update
    sudo apt-get -y upgrade
    # echo "$(date +%Y-%m-%dT%H:%M:%S)" > "$flag"

    # command -v pyenv && pyenv update

    date +%Y-%m-%dT%H:%M:%S > "$flag"
}

check_for_os_updates