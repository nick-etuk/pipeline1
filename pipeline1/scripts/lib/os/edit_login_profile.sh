#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2129

parse_template() {
    local template_file
    local template_content
	local pyenv_shell
	
	pyenv_shell=$1

    template_file=$(find "$P1_ROOT_UNIX" -name 'login_profile_unix.template.sh' -type f -not -path '.venv_p1/*')

    [ "$template_file" ] || return

    template_content=$(<"$template_file")
    template_content=${template_content//'{{P1_VERSION}}'/"$P1_VERSION"}
    template_content=${template_content//'{{P1_ROOT_UNIX}}'/"$P1_ROOT_UNIX"}
    template_content=${template_content//'{{WORKING_DIR}}'/"$WORKING_DIR"}
	template_content=${template_content//'{{SHELL_NAME}}'/"$pyenv_shell"}

    echo "$template_content"
}

function add_to_profile {
    local target
	local pyenv_shell

    target=$1
    [ -f "$target" ] || return 0

	P1_VERSION='2.0'  # todo: remove this duplicate declaration

    grep -iq "pipeline1_v$P1_VERSION" "$target" && return 0

	case $target in
		~/.zshrc)
			pyenv_shell='zsh'
			;;
		~/bashrc)
			pyenv_shell='bash'
			;;
		~/.config/fish/config.fish)
			pyenv_shell='fish'
			;;
		*)
			echo "Edit login profile: Unknown Pyenv shell for $target"
			return
			;;
	esac
	
    profile_content=$(parse_template $pyenv_shell)

    if [ "$target" = ~/.zshrc ]; then
        # Add commands to top of file to avoid problems with p10k-instant-prompt
        echo "$profile_content" > "/tmp/zshrc.tmp"

        printf "\n" | cat - "$target" >> "/tmp/zshrc.tmp"
        mv /tmp/zshrc.tmp "$target"
        echo "Added login script to top of $target"
    else
        printf "\n" >> "$target"
        echo "$profile_content" >> "$target"
        echo "Added login script to bottom of $target"
    fi
}

edit_login_profile() {
	[ -f ~/.hushlogin ] || touch ~/.hushlogin

	# If there are multiple login profiles, modify them all.
	add_to_profile ~/.bashrc
	add_to_profile ~/.zshrc
	add_to_profile ~/.config/fish/config.fish
}
