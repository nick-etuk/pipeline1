#!/usr/bin/env bash

function add_aliases {
    if alias | grep -iq memhogs; then
        echo "Aliases already set"
        return
    fi

    alias gch='git checkout'
    alias gs='git status'
    # alias gls='git log --show-signature --oneline --graph --decorate --all'
    alias gls='git log --show-signature'

    alias cd..='cd ../'
    alias ..='cd ../'
    alias ...='cd ../../'
    alias .3='cd ../../../'
    alias ~="cd ~"
    alias kill='kill -9'
    alias path='echo -e ${PATH//:/\\n}'       # system: Echo all executable Paths

    alias memhogs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10' # system: Show top 10 memory hogs
    alias cpuhogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'      # system: Show top 10 cpu hogs

    # alias cleanbuild='[ -n "$(docker images -aq)" ] && docker rmi -f "$(docker images -aq)"; docker system prune -f && cd "$REPO_DIR/nhsapp/web" && npm install && cd .. &&  make clean && make login && make build'

    alias h='history|grep -i'

    startup_script=$(find "$P1_ROOT_UNIX" -name "p1.py" -not -path ".venv_p1/*")
    if [ -f "$startup_script" ] ; then
        p1() { python3 "$startup_script" "$@"; }
        menu() { python3 "$startup_script" "$@"; }
        p1web() { python3 "$startup_script" web "$@"; }
        p1bdd() { python3 "$startup_script" bdd "$@"; }
        p1and() { python3 "$startup_script" and "$@"; }
        p1xit() { python3 "$startup_script" xit "$@"; }
    fi

    alias cdp1='cd "$P1_ROOT_UNIX"'
    # todo: add cdweb, cdand etc. i.e cd<project> for all projects
    
    EDITOR="$(command -v nano || command -v vi || command -v vim || echo "/usr/bin/nano")"
    export EDITOR
}