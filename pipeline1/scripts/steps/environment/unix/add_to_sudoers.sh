#!/usr/bin/env bash

P1_USER_UNIX=$(cat /var/tmp/wsl-users.txt)
if [ -z "$P1_USER_UNIX" ]; then
    echo "No WSL user file. Using WSL default user."
    P1_USER_UNIX=$(getent passwd 1000 | cut -d: -f1)
fi
info "Adding user $P1_USER_UNIX to sudoers"

echo "$P1_USER_UNIX ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/90-sudo-nopasswd
