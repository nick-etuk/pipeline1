#!/usr/bin/env bash

create_venv() {
    venv_dir="$P1_ROOT_UNIX/.venv_p1"
    if [ ! -d "$venv_dir" ]; then
        # prompt before creating venv
        read -rp "Python virtual environment not found. Do you want one created? (y/n) " create_venv
        if [ "$create_venv" = "y" ]; then
            echo 'Creating Python virtual environment .venv_p1'
            venv_dir="$P1_ROOT_UNIX/.venv_p1"
            python3 -m venv "$venv_dir"
        else
            echo 'Aborting.'
            exit 1
        fi
    fi

    if [ -z "${VIRTUAL_ENV+set}" ]; then
        echo 'Activating virtual environment...'
        venv_activate="$P1_ROOT_UNIX/.venv_p1/bin/activate"
        [ -f "$venv_activate" ] && source "$venv_activate"
    fi
}
