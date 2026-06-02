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

    P1_STARTUP=$(find "$P1_ROOT_UNIX" -name "p1.sh" -not -path ".venv_p1/*")
    if [ -f "$P1_STARTUP" ] ; then
        p1() { "$P1_STARTUP" "$@"; }
        menu() { "$P1_STARTUP" "$@"; }
        p1web() { "$P1_STARTUP" web "$@"; }
        p1bdd() { "$P1_STARTUP" bdd "$@"; }
        p1and() { "$P1_STARTUP" and "$@"; }
        p1xit() { "$P1_STARTUP" xit "$@"; }
    fi

    alias cdp1='cd "$P1_ROOT_UNIX"'
    # todo: add cdweb, cdand etc. i.e cd<project> for all projects
    alias cdweb='cd "$REPO_DIR/nhsapp/web"'
    alias cdand='cd "$REPO_DIR/nhsapp-android"'
    alias cdios='cd "$REPO_DIR/nhsapp-ios"'
    
    EDITOR="$(command -v nano || command -v vi || command -v vim || echo "/usr/bin/nano")"
    export EDITOR
}