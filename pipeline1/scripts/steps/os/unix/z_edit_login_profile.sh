#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2129

function add_to_profile {
    local target
    local shell_name
    local lines=()
    lines=(
        "# pipeline1_v$P1_VERSION start"
        "export P1_ROOT_UNIX=\"$P1_ROOT_UNIX\""
        'export GPG_TTY=$(tty)'
        ''
        'export NVM_DIR="$HOME/.nvm"'
        '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
        '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
        ''
        'if [ -d "$HOME/.pyenv" ]; then'
        '   export PYENV_ROOT="$HOME/.pyenv"'
        '   [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
        "   eval \"\$(pyenv init - $shell_name)\""
        'fi'
        ''
        'startup_script=$(find "$P1_ROOT_UNIX" -name "p1.py" -not -path ".venv_p1/*")'
        'if [ -f "$startup_script" ] ; then'
        '  p1() { python3 "$startup_script" "$@"; }'
        '  menu() { python3 "$startup_script" "$@"; }'
        'fi'
        'login_script=$(find "$P1_ROOT_UNIX/src/core/steps" -name "terminal_login.sh" -not -path ".venv_p1/*")'
        '[ -f "$login_script" ] && . "$login_script"'
        'set +u # stops oh-my-zsh.sh failing due to unset variables'
        "# pipeline1_v$P1_VERSION end"
    )

    target=$1

    [ -f "$target" ] || return 0

    grep -q "pipeline1_v$P1_VERSION" "$target" && return 0
    grep -q "workstation1_v$P1_VERSION" "$target" && return 0


    if [ "$target" = ~/.zshrc ]; then
        # Add commands to top of file to avoid problems with p10k-instant-prompt
        echo "${lines[0]}" > "/tmp/zshrc.tmp"
        for line in "${lines[@]:1}"; do
            echo "$line" >> "/tmp/zshrc.tmp"
        done
        printf "\n" | cat - "$target" >> "/tmp/zshrc.tmp"
        mv /tmp/zshrc.tmp "$target"
        info "Added login script to top of $target"
    else
        printf "\n" >> "$target"
        for line in "${lines[@]}"; do
            echo "$line" >> "$target"
        done
        info "Added login script to bottom of $target"
    fi
}
echo "=> edit_login_profile"
# return
[ -f ~/.hushlogin ] || touch ~/.hushlogin

login_script=$(find "$P1_ROOT_UNIX/core/steps" -name "terminal_login.sh" -type f)
[ -f "$login_script" ] || return

# If there are multiple login profiles, add to all of them
shell_name='zsh'
add_to_profile ~/.zshrc
add_to_profile ~/.config/fish/config.fish
shell_name='bash'
add_to_profile ~/.bashrc
