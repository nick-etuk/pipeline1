#!/usr/bin/env bash

invoke_step_exit() {
    # local args
    local step
    local parallel='false'
    local exit_status

    # debug "bp5 =>invoke_step_exit"
    # if [ "$#" -eq 1 ]; then
    #     step="$1"
    #     debug "bp6 step: $step"
    # else
    #     debug "multiple args: >$*<"
    # fi

    OPTIND=1 # stops repeated calls to getopts from failing
    # while getopts "o:s:p:" opt; do
    while getopts "s:p:" opt; do
        case ${opt} in
            s)
                step=$OPTARG
            ;;
            # o)
            #     run_once=$OPTARG
            # ;;
            p)
                parallel=$OPTARG
            ;;
            \?)
                warn "Invalid option $opt. Please specify a step with the -s option."
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    # args=("$@")

    if [ "$parallel" = 'true' ]; then
        # wait_for_parallel_step "$step" ${args[@]+"${args[@]}"}
        wait_for_parallel_step "$step" "$@"
        exit_status=$WAIT_FOR_STEP_STATUS
        if [ "$exit_status" -ne 0 ]; then
            # Don't worry about the nested double quotes below.
            # Sub-shell starts a new quoting context
            warn "$(get_step_description "$step") parallel step failed" 
            return "$exit_status"
        fi
    fi

    [ "$NEW_TAB" = 'true' ] && [[ 'start_service build_backend' == *$step* ]] && return 0
    # assert_step_done "$step" ${args[@]+"${args[@]}"} 
    assert_step_done "$step" "$@"
    exit_status=$?
    if [ "$exit_status" -ne 0 ]; then
        warn "$(get_step_description "$step") step failed"
    fi
    return "$exit_status"
}