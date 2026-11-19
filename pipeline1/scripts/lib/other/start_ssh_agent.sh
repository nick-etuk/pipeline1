#!/usr/bin/env bash

add_ssh_key() {
    local ssh_key
    ssh_key=$1

    if [ ! -d "$HOME/.ssh" ] || [ ! -f "$HOME/.ssh/$ssh_key" ] || [ ! -f "$HOME/.ssh/$ssh_key.pub" ]
    then
        info "SSH key pair $ssh_key not found."
        return
    fi

    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/$ssh_key"
    chmod 644 "$HOME/.ssh/$ssh_key.pub"

    # todo: check if the key is already added to the agent
    # identities=$(ssh-add -L 2>/dev/null)
    # if [[ $identities == *"ssh-ed25519"* ]]; then
    #     info "SSH key is already added."
    #     return
    # fi

    info "Adding ssh key $ssh_key..."
    ssh-add "$HOME/.ssh/$ssh_key"
}

start_ssh_agent() {
    if [ -n "${SSH_AGENT_PID+set}" ] && ps -p "$SSH_AGENT_PID" > /dev/null
    then
        info "ssh agent is already running. PID: $SSH_AGENT_PID"
        return
    fi

    info "Starting ssh-agent"
    eval "$(ssh-agent -s)"
    if [ -z "${SSH_AGENT_PID+set}" ]; then
        warn 'Failed to start ssh agent'
        return
    fi
}
