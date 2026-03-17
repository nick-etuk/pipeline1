#!/usr/bin/env bash
# shellcheck disable=SC1091,SC1090

create_venv() {
    # venv_dir=$(find "$P1_ROOT_UNIX" -name '.venv_p1' -type d)
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
    # echo "VIRTUAL_ENV:"
    # echo "${VIRTUAL_ENV+set}"
    if [ -z "${VIRTUAL_ENV+set}" ]; then
        echo 'Activating virtual environment...'
        # venv_activate=$(find "$P1_ROOT_UNIX" -name 'activate')
        venv_activate="$P1_ROOT_UNIX/.venv_p1/bin/activate"
        [ -f "$venv_activate" ] && source "$venv_activate"
    fi

}

current_dir=$(dirname "$(realpath "$0")")
cd "$current_dir" || exit


if [ -z "${P1_ROOT_UNIX+set}" ]; then
    echo 'Setting P1_ROOT_UNIX manually.'
    echo 'printenv | grep P1_ROOT_UNIX:'
    printenv | grep P1_ROOT_UNIX
    P1_ROOT_UNIX="$current_dir"
fi

if [ -z "${P1_ROOT_SCRIPT+set}" ]; then
    echo 'p1.sh setting P1_ROOT_SCRIPT'
    init_script=$(find "$P1_ROOT_UNIX" -name 'init.sh' -not -path '.venv_p1/*')
    P1_ROOT_SCRIPT=$(dirname "$init_script")
fi

if [ -z "${INIT_UNIX+set}" ]; then
    init_script="$P1_ROOT_SCRIPT/init.sh"
    [ -f "$init_script" ] && source "$init_script"
fi

# todo: run check_for_os_updates.sh, install_pyenv here
# create_venv
# add_to_path
# add_aliases

if ! pip list | grep -q 'pipeline1'; then
    echo 'Installing pipeline1 package...'
    # pip install -r "$P1_ROOT_UNIX/requirements.txt"   # todo: fix this. Currently doesn't work for some reason.
    pip install -e "$P1_ROOT_UNIX"
fi

startup_script="$P1_ROOT_UNIX/pipeline1/p1.py"
python3 "$startup_script" "$@"
