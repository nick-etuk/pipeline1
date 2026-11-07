#!/usr/bin/env bash

# Must be run as a superuser

add_to_sudoers(){
	local os_param
	local my_sudoers_file

	# todo: rethink this
	# Could use $MY_OS instead of $os_param, but this script is run with sudo, so MY_OS is not set. Need to pass it in as a parameter.	
	# What does /var/tmp/wsl-users.txt do? It is created in get_wsl_win_info.sh, but that script is not run in this script. So if this script is run without running get_wsl_win_info.sh first, the file will not exist. Need to check for that and create it if it does not exist.	
	# Is there a way of doing this once instead of every login? Perhaps set a context variable.
	return 0
	
	os_param=$1
	[ "$os_param" = 'macos' ] && return

	if [ -z "${P1_USER_UNIX+set}" ];then
		if [ -f /var/tmp/wsl-users.txt ]; then
			P1_USER_UNIX=$(cat /var/tmp/wsl-users.txt)
		fi
		[ -z "$P1_USER_UNIX" ] && P1_USER_UNIX=$(whoami)
	fi
	my_sudoers_file='/etc/sudoers.d/90-sudo-nopasswd'
	
	[ -f $my_sudoers_file ] && grep -q "$P1_USER_UNIX" $my_sudoers_file && return
	
	echo "Adding user $P1_USER_UNIX to sudoers"

	echo "$P1_USER_UNIX ALL=(ALL) NOPASSWD: ALL" >> $my_sudoers_file
}
add_to_sudoers "$@"
