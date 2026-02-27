#!/usr/bin/env bash

invoke_step_entry() {
    local step_id
    local args
    # local run_once=''

    OPTIND=1 # stop repeated call to getopts from failing
    while getopts "s:" opt; do
        case ${opt} in
            s)
                step_id=$OPTARG
            ;;
            # o)
            #     run_once=$OPTARG
            # ;;
            \?)
                warn "Invalid option $opt. Please specify a step with the -s option."
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    args=("$@")

    if ! check_dependencies "$step_id" ${args[@]+"${args[@]}"}; then
        return 1
    fi
    if assert_step_done "$step_id" ${args[@]+"${args[@]}"}; then
        info "$(get_step_description "$step_id") step already done"
        return 1
    fi
}
