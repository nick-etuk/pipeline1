#!/usr/bin/env bash

daily_tasks() {
    # Should update_remote_steps be done in python? Also check_for_os_updates?
    # Yes, it should be done in Python because the logic is complex.
    # No, check_for_os_updates should be done in bash 
    # because it is close to the OS, should be done before invoking Python, and is not complex.
    local last_update
    local flag
    
    flag="$WORKING_DIR/daily_tasks.txt"
    if [ -f "$flag" ] && [ -s "$flag" ]; then
        last_update=$(cat "$flag")
        if [ "$MY_OS" = 'macos' ]; then
            # macOS date command uses -j and -f for parsing, and +%s for epoch time
            if [ "$(date -j -f "%Y-%m-%dT%H:%M:%S" "$last_update" +"%s")" -ge "$(date -v-1d +"%s")" ]; then
                echo "Daily tasks already completed on $(date -j -f "%Y-%m-%dT%H:%M:%S" "$last_update" +"%A %d %B %Y at %H:%M")"
            fi
            return
        else
            if [ "$(date -d "$last_update" +%s)" -ge "$(date +%s --date '1 day ago')" ]; then
                echo "Daily tasks already completed on $(date -d "$last_update" +'%A %d %B %Y at %H:%M')"
            fi
            return
        fi
    fi
    check_for_os_updates

    date +%Y-%m-%dT%H:%M:%S > "$flag"
}
