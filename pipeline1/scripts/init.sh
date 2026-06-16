#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1090

set -u

[ -n "${INIT_UNIX+set}" ] && return

INIT_UNIX=1
CURRENT_STEP=''

[ -z "${FORCE+set}" ] && FORCE=0
[ -z "${DEBUG+set}" ] && DEBUG=1


if [ -z "${P1_ROOT_SCRIPT+set}" ];then
    P1_ROOT_SCRIPT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    echo "Init.sh set P1_ROOT_SCRIPT to $P1_ROOT_SCRIPT"
    cd "$P1_ROOT_SCRIPT" || { echo "Could not switch to directory $P1_ROOT_SCRIPT"; exit 1; }
fi

echo -n 'p1'
libraries=$(find "$P1_ROOT_SCRIPT/lib" -name '*.sh' -type f ! -name 'config_base.sh' ! -name 'z*.sh')
for library in $libraries; do
    source "$library"
    echo -n "."
done
echo ''

# Run config_base.sh last, as it is script, not a library.
script=$(find "$P1_ROOT_SCRIPT/lib" -name 'config_base.sh' -type f)
source "$script"

get_next_run_id
LOG_DIR="$LOG_BASE/$RUN_ID"
mkdir -p "$LOG_DIR"

get_context
# show_config
