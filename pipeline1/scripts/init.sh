#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1090

set -u

[ -n "${INIT_UNIX+set}" ] && return

INIT_UNIX=1
CURRENT_STEP='general'

[ -z "${FORCE+set}" ] && FORCE=0
[ -z "${DEBUG+set}" ] && DEBUG=1

# [ -z "${SERIAL_ONLY+set}" ] && SERIAL_ONLY='false'
[ -z "${NEW_TAB+set}" ] && NEW_TAB='false'

if [ -z "${P1_ROOT_SCRIPT+set}" ];then
    P1_ROOT_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    # P1_ROOT_UNIX=$( cd -- "$( dirname -- "${P1_ROOT_SCRIPT}/../.." )" &> /dev/null && pwd )
    echo "Init.sh set P1_ROOT_SCRIPT to $P1_ROOT_SCRIPT"
    cd "$P1_ROOT_SCRIPT" || exit 1
fi

echo -n 'p1'
libraries=$(find "$P1_ROOT_SCRIPT/lib" -name '*.sh' -type f ! -name 'config_ubuntu.sh' ! -name 'config_macos.sh' ! -name 'z*.sh')
for library in $libraries; do
    source "$library"
    echo -n "."
done
echo ''

get_next_run_id
LOG_DIR="$LOG_BASE/$RUN_ID"
mkdir -p "$LOG_DIR"

# set_repo_dir todo: delete if unused

# DONE_DEPENDENCIES=()
get_context
# show_p1_config
echo "SHELL:                    $SHELL_NAME version: $SHELL_VERSION"
