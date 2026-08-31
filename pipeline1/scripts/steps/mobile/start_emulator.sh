#!/usr/bin/env bash

function start_emulator_ios {
    open -a Simulator.app
    "wait_for_emulator_ios"
}

function start_emulator_android {
    local mode
    mode="$1"

    case "$mode" in
        "writable")
            echo 'Starting Android emulator in writable mode.'
            echo 'Remember to provide a hosts file.'
            emulator -avd $ANDROID_DEFAULT_DEVICE -no-snapshot-load -writable-system
            "wait_for_emulator_android"
            ;;
        *)
            echo 'Starting Android emulator that point to a backend with URL of http://localhost:3100...'
            emulator -avd $ANDROID_DEFAULT_DEVICE -no-snapshot-load -writable-system
            wait_for_emulator_android
            adb reverse tcp:3100 tcp:3100
            ;;
    esac
}

function start_emulator {
    local platform
    local mode

    platform="$1"
    mode="$2"

    "start_emulator_$platform" "$mode"
}
