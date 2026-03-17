#!/usr/bin/env bash

check_for_os_updates() {
    local last_update
    local flag
    
    [ -z "${MY_OS+empty_string}" ] && return

    [ "$MY_OS" != "ubuntu" ] && return

    echo 'Updating OS packages...'
    sudo apt-get update
    sudo apt-get -y upgrade
}