# Pipeline1_v{{P1_VERSION}} start
export P1_ROOT_UNIX='{{P1_ROOT_UNIX}}'
export REPO_DIR=$(dirname "$P1_ROOT_UNIX")
export P1_ROOT_SCRIPT="$P1_ROOT_UNIX/pipeline1/scripts"
export PATH="$PATH:$P1_ROOT_SCRIPT"
export GPG_TTY=$(tty)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - {{SHELL_NAME}})"
fi

. "$P1_ROOT_UNIX/.venv_p1/bin/activate"
login_script="$P1_ROOT_SCRIPT/terminal_login.sh"

# if any scripts in $P1_ROOT_SCRIPT are not executable, make them so
for file in "$P1_ROOT_SCRIPT"/*.sh; do
  [ ! -x "$file" ] && chmod +x "$file"
done

[ -f "$login_script" ] && . "$login_script"
set +u # stops oh-my-zsh.sh failing due to unset variables
# Pipeline1_v{{P1_VERSION}} end
