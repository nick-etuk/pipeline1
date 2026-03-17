#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2129

parse_template() {
    local template_file
    local template_content

    template_file=$(find "$P1_ROOT_UNIX" -name "login_profile_template_unix.*" -type f -not -path '.venv_p1/*')

    [ "$template_file" ] || return

    template_content=$(<"$template_file")
    template_content=${template_content//'{{P1_ROOT_UNIX}}'/"$P1_ROOT_UNIX"}
    template_content=${template_content//'{{WORKING_DIR}}'/"$WORKING_DIR"}

    echo "$template_content"
}

function add_to_profile {
    local target
    local shell_name

    target=$1

    [ -f "$target" ] || return 0

    grep -q "pipeline1_v$P1_VERSION" "$target" && return 0
    grep -q "workstation1_v$P1_VERSION" "$target" && return 0

    profile_content=$(parse_template)

    if [ "$target" = ~/.zshrc ]; then
        # Add commands to top of file to avoid problems with p10k-instant-prompt
        echo "$profile_content" > "/tmp/zshrc.tmp"

        printf "\n" | cat - "$target" >> "/tmp/zshrc.tmp"
        mv /tmp/zshrc.tmp "$target"
        info "Added login script to top of $target"
    else
        printf "\n" >> "$target"
        echo "$profile_content" >> "$target"
        info "Added login script to bottom of $target"
    fi
}
echo "=> edit_login_profile"
# return
[ -f ~/.hushlogin ] || touch ~/.hushlogin

login_script=$(find "$P1_ROOT_UNIX/core/steps" -name "terminal_login.sh" -type f)
[ -f "$login_script" ] || return

# If there are multiple login profiles, modify them all.
shell_name='zsh'
add_to_profile ~/.zshrc
add_to_profile ~/.config/fish/config.fish
shell_name='bash'
add_to_profile ~/.bashrc
