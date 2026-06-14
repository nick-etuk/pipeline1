#!/usr/bin/env bash

do_tasks() {
    check_for_os_updates
    date +%Y-%m-%dT%H:%M:%S > "$1"
}

daily_tasks() {
    local last_update
    local flag_dir
    local flag_file
    
    flag_dir="$WORKING_DIR/context/global"
    flag_file="$flag_dir/daily_tasks.txt"
    if [ ! -f "$flag_file" ]; then
        mkdir -p "$flag_dir"
        touch "$flag_file"
        do_tasks "$flag_file"
        return
    fi

    if [ ! -s "$flag_file" ]; then
        do_tasks "$flag_file"
        return
    fi

    last_update=$(cat "$flag_file")
    if [ "$MY_OS" = 'macos' ]; then
        # macOS date command uses -j and -f for parsing, and +%s for epoch time
        if [ "$(date -j -f "%Y-%m-%dT%H:%M:%S" "$last_update" +"%s")" -ge "$(date -v-1d +"%s")" ]; then
            echo "Daily tasks done today ($(date -j -f "%Y-%m-%dT%H:%M:%S" "$last_update" +"%A %d %B %Y at %H:%M"))"
            return
        fi
    else
        if [ "$(date -d "$last_update" +%s)" -ge "$(date +%s --date '1 day ago')" ]; then
            echo "Daily tasks done today ($(date -d "$last_update" +'%A %d %B %Y at %H:%M'))"
            return
        fi
    fi

    do_tasks "$flag_file"
}
