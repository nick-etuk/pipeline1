#!/usr/bin/env bash
function wait_for_emulator_android {
    info "Waiting for android emulator to start"
    while ! adb -s emulator-"$ANDROID_EMULATOR_PORT" shell echo 'I am alive'; do
        sleep 5
        echo -n "."
    done
    echo ""
}

function wait_for_emulator_ios {
    info "Waiting for ios emulator to start"
    while ! ps aux | grep -v grep | grep -iq 'Simulator.app'; do
        sleep 5
        echo -n "."
    done
    echo ""
}
