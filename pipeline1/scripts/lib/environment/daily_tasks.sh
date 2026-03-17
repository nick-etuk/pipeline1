#!/usr/bin/env bash

daily_tasks() {
    local last_update
    local flag
    
    flag="$WORKING_DIR/daily_tasks.txt"
    if [ -f "$flag" ] && [ -s "$flag" ]; then
        last_update=$(cat "$flag")
        if [ "$(date -d "$last_update" +%s)" -ge "$(date +%s --date '1 day ago')" ]; then
            echo "Daily tasks already completed on $(date -d "$last_update" +'%A %d %B %Y at %H:%M')"
            return
        fi
    fi
    check_for_os_updates
    update_remote_steps

    date +%Y-%m-%dT%H:%M:%S > "$flag"
}
