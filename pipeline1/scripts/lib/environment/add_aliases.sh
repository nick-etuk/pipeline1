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

    # startup_script="$P1_ROOT_UNIX/p1.sh"
    if [ -f "$startup_script" ] ; then
        web() { "$startup_script" web "$@"; }
        bdd() { "$startup_script" bdd "$@"; }
        and() { "$startup_script" and "$@"; }
        xit() { "$startup_script" xit "$@"; }
    fi

    EDITOR="$(command -v nano || command -v vi || command -v vim || echo "/usr/bin/nano")"
    export EDITOR
}