#!/usr/bin/env bash

function check_ide {
    local ide
    local search_string
    # local search_result

    ide="$1_$MY_OS"
    debug "=>check_ide $ide"
    case "$ide" in
        android_macos )
            search_string='Android Studio.app'
            ;;
        intellij_macos )
            search_string='IntelliJ IDEA'
            ;;
        xcode_macos )
            search_string='Xcode.app'
            ;;
        vscode_macos )
            search_string='Visual Studio Code.app'
            ;;
        vscode_ubuntu )
            search_string='vscode'
            ;;
        * )
            warn "Unknown IDE $ide"
        ;;
    esac
    ps aux | grep -v grep | grep -iq "$search_string" || return 1
    # search_result=$(ps aux | grep -v grep | grep -iq "$search_string")
    # [ -z "$search_result" ] && return 1
}