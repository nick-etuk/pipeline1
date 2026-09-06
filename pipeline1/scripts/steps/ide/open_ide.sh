#!/usr/bin/env bash

open_ide() {
    local ide
    local location_win

    ide="$1_$MY_OS"
    location="$2"

    case "$ide" in
        android_studio_macos)
            open -a "/Applications/Android Studio.app" "$location"
            ;;
        android_studio_ubuntu)
            location_win=$(wslpath "$location")
            studio64.exe "$location_win"
            ;;
        intellij_macos)
            open -na "IntelliJ IDEA CE.app" "$location"
            ;;
        intellij_ubuntu)
            idea64.exe "$location"
            ;;
        xcode_macos)
            xed "$location"
            ;;        
        vscode_macos )
            open -na "Visual Studio Code.app" "$location"
            ;;
        vscode_win)
            code "$location"
            ;;
        vscode_ubuntu)
            code "$location"
            ;;
        rider_macos)
            rider "$location"
            ;;
        *)
            error "Unknown IDE: $ide"
    esac
    sleep 5
}

open_ide "$1"