#!/usr/bin/env bash

check_for_os_updates() {
    local last_update
    local flag
    
    [ -z "${MY_OS+empty_string}" ] && return

    [ "$MY_OS" != "ubuntu" ] && return
	
	source	/etc/os-release
	[[ ! $PRETTY_NAME == *24.04* ]] && echo 'Warning: Pipeline1 is optimised for Ubuntu 24.04.'

    echo 'Updating OS packages...'
    sudo apt-get update
    sudo apt-get -y upgrade
}
