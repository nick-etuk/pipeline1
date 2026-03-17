#!/usr/bin/env bash

function add_to_path {
    local paths_to_add

    paths_to_add=(
        "$(dirname "$login_script")"
        "$HOME/.local/bin"
        "$HOME/Library/Android/sdk/emulator"
        "$HOME/Library/Android/sdk/platform-tools"
    )

    [ "$MY_OS" = 'macos' ] && paths_to_add+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")

    for new_path in "${paths_to_add[@]}"; do
        if [[ ! $PATH == *$new_path* ]]; then
            export PATH="$PATH:$new_path"
            echo "Added $new_path to path"
        fi
    done
}
