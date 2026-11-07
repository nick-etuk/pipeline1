#!/usr/bin/env bash

start_ssh_agent() {
    if [ ! -d ~/.ssh ] || [ ! -f ~/.ssh/id_ed25519 ] || [ ! -f ~/.ssh/id_ed25519.pub ]
    then
        info "SSH key pair not found."
        return
    fi

    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_ed25519
    chmod 644 ~/.ssh/id_ed25519.pub


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

    identities=$(ssh-add -L 2>/dev/null)
    if [[ $identities == *"ssh-ed25519"* ]]; then
        info "SSH key is already added."
        return
    fi

    info "Adding ssh key..."
    ssh-add ~/.ssh/id_ed25519
}
