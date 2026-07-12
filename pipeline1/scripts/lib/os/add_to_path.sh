#!/usr/bin/env bash

set_android_sdk_path() {
    [ -n "${ANDROID_SDK_ROOT+set}" ] && return

    if [ "$MY_OS" = 'macos' ]; then
        export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
        return
    fi
    
    # todo: I don't think this should only be done in wsl. Only windows, MacOS and Ubuntu.
    # if [ "$VM" = 'wsl' ]; then
        # WINDOWS_APP_INSTALL_DIR=$(get_context 'windows_app_install_dir');
        # export ANDROID_SDK_ROOT="$WINDOWS_APP_INSTALL_DIR/android_sdk"
    #     return
    # fi
    
    WINDOWS_APP_INSTALL_DIR=$(get_context 'windows_app_install_dir');
    export ANDROID_SDK_ROOT="$WINDOWS_APP_INSTALL_DIR/android_sdk"
}

set_android_home() {
    [ -n "${ANDROID_HOME+set}" ] && return

    export ANDROID_HOME="$ANDROID_SDK_ROOT"
}

function add_to_path {
    local paths_to_add


    set_android_sdk_path
    set_android_home
    
    paths_to_add=(
        "$P1_ROOT_SCRIPT"
        "$HOME/.local/bin"
        "$ANDROID_SDK_ROOT/emulator"
        "$ANDROID_SDK_ROOT/platform-tools"
    )

    [ "$MY_OS" = 'macos' ] && paths_to_add+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")

    for new_path in "${paths_to_add[@]}"; do
        if [[ ! $PATH == *$new_path* ]]; then
			PATH="$PATH:$new_path"
            export PATH
            echo "Added $new_path to path"
        fi
    done
}
