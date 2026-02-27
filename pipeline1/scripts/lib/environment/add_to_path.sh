#!/usr/bin/env bash

function add_to_path {
    local paths_to_add

    # startup_script="$P1_ROOT_UNIX/p1.sh"

    paths_to_add=(
        "$(dirname "$startup_script")"
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

    # export PATH=$PATH:"$P1_ROOT_UNIX"
    # export PATH=$PATH:"/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    # export PATH=$PATH:"$HOME/Library/Android/sdk/emulator"
    # export PATH=$PATH:"$HOME/Library/Android/sdk/platform-tools"
}
