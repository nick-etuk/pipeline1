#!/usr/bin/env bash

function set_android_env_vars {
    [ -z "${ANDROID_HOME+set}" ] && export ANDROID_HOME="$HOME/Library/Android/sdk"
    [ -z "${ANDROID_SDK_ROOT+set}" ] && export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
}

function add_to_path {
    local paths_to_add

    # todo: add the correct paths for Ubuntu
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
    set_android_env_vars
}
