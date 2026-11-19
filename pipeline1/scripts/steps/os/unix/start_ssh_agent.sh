#!/usr/bin/env bash

start_ssh_agent
add_ssh_key "id_ed25519_nhs"
add_ssh_key "id_ed25519_nick_etuk"

# ssh-add -L 2>/dev/null
ssh-add -L