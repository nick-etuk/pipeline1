#!/usr/bin/env bash

# Must be run as a superuser

add_to_sudoers(){
	local os_param
	local my_sudoers_file
	
	os_param=$1
	[ "$os_param" = 'macos' ] && return

	P1_USER_UNIX=$(cat /var/tmp/wsl-users.txt)
	[ -z "$P1_USER_UNIX" ] && P1_USER_UNIX=$(whoami)
	
	my_sudoers_file='/etc/sudoers.d/90-sudo-nopasswd'
	
	[ -f $my_sudoers_file ] && grep -q "$P1_USER_UNIX" $my_sudoers_file && return
	
	echo "Adding user $P1_USER_UNIX to sudoers"

	echo "$P1_USER_UNIX ALL=(ALL) NOPASSWD: ALL" >> $my_sudoers_file
}
add_to_sudoers "$@"
