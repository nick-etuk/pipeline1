#!/usr/bin/env bash

open_ide() {
    local ide
    local repo_dir_win
    ide="$1_$MY_OS"

    case "$ide" in
        android_macos)
            open -a "/Applications/Android Studio.app" "$REPO_DIR/nhsapp-android"
            ;;
        android_ubuntu)
            repo_dir_win=$(wslpath "$REPO_DIR")
            studio64.exe "$repo_dir_win/nhsapp-android"
            ;;
        bdd_macos)
            open -na "IntelliJ IDEA CE.app" "$REPO_DIR/nhsapp/bddtests"
            ;;
        ios_macos)
            xed "$REPO_DIR/nhsapp-ios"
            ;;        
        web_macos )
            open -na "Visual Studio Code.app" "$REPO_DIR/nhsapp/web"
            ;;
        web_ubuntu)
            code "$REPO_DIR/nhsapp/web"
            ;;
        xit_macos)
            rider "$REPO_DIR/nhsapp/xamarinintegrationtests/NHSOnline.IntegrationTests.sln"
            ;;
        *)
            error "Unknown IDE: $ide"
    esac
    sleep 5
}

open_ide "$1"