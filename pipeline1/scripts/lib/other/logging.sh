#!/usr/bin/env bash
set_log_dir() {
    if [ -z "${LOG_BASE+set}" ]; then
        LOG_BASE="$P1_ROOT_SCRIPT/log"
    fi
    if [ -z "${RUN_ID+set}" ]; then
        get_next_run_id
    fi
    LOG_DIR="$LOG_BASE/$RUN_ID"
    mkdir -p "$LOG_DIR"
}

write_log() {
    [ -z "${LOG_DIR+set}" ] && set_log_dir
    echo "$*" >> "$LOG_DIR/$CURRENT_STEP.log"
    echo "$*" >> "$LOG_DIR/z_all_steps.log"
}

function info {
    # todo: get stage (filename of calling script) automatically
    # PARENT_COMMAND=$(ps -o args= $PPID)
    # PARENT_COMMAND=$(ps $PPID | tail -n 1 | awk "{print \$5}")
    # echo "PPID, PARENT_COMMAND:$PPID, $PARENT_COMMAND"
    # STAGE=$PARENT_COMMAND

    # LOG_FILE="/mnt/c/provisioning/log/$STAGE-$(date +%Y-%m-%d).log"
    # echo "[$(date +'%Y-%m-%d %H:%M:%S')]:[$STAGE] $*" | tee -a $LOG_FILE
    local message
    local modified_message
    local silent_steps

    message="$*"
    silent_steps=('core_steps' 'Core steps' 'Clone templates' 'Setup terminal')
    silent_messages=('step started' 'step completed' 'step already done')

    for step in "${silent_steps[@]}"; do
        for silence in "${silent_messages[@]}"; do
            if [ "$message" = "$step $silence" ]; then
                return
            fi
        done
    done

    modified_message=$(echo -e "${message/step completed/$TICK_MARK}")
    modified_message=$(echo -e "${modified_message/step already done/$TICK_MARK}")
    modified_message=$(echo -e "${modified_message/step failed/$CROSS_MARK}")

    # log "[$(date +'%Y-%m-%d %H:%M:%S')] $modified_message"
    echo "$modified_message"
    write_log "$modified_message"
}

function error {
    echo -e "${RED}Error in ${FUNCNAME[1]}:$*${NC}"
    write_log "$*"
    exit 1
}

function warn {
    echo -e "${YELLOW}$*${NC}"
    write_log "$*"
}

function debug {
    # [ "$DEBUG" -ne 1 ] && return
    echo -e "${YELLOW}$*${NC}"
    write_log "$*"
}
