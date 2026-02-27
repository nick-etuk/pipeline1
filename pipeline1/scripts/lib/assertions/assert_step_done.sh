#!/usr/bin/env bash

assert_step_done() {
    local args
    local step
    local exit_status
    local calling_function
    local config_file
    local checks
    local debug_mode=0
    local debug_mode_json
    local os_checks_json
    local os_checks_tsv
    local unix_checks_json
    local unix_checks_tsv

    step=$1
    shift
    args=( "$@" )

    # [[ $step == start* ]] && return 1

    if [ -z ${FUNCNAME[0]+empty_string} ]; then
        # Called by a top-level script, not a function
        calling_function=''
    else
        # Called by a function
        calling_function=${FUNCNAME[1]}
        [ "$SHELL_NAME" = 'zsh' ] && calling_function=${FUNCNAME[2]}
    fi

    config_file=$(get_step_path "$step")
    if [ -z "$config_file" ]; then
        error "No configuration file for $step. Called by $calling_function"
    fi

    # debug "checking $step ${args[*]+"${args[*]}"} for $calling_function"

    if [ "$FORCE" -eq 1 ]; then
        if [[ $config_file == *core/* ]]; then
            [ "$calling_function" =  'invoke_step_entry' ] && info "$step is a core step, so we will not force it."
        else
            if [ "$calling_function" = 'check_dependencies' ]; then 
                info "Forcibly passing dependency $step"
                return 0
            fi
            if [ "$calling_function" =  'invoke_step_entry' ]; then
                info "Forcing $step"
                return 1
            fi
        fi
    fi
    
    checks=()
    debug_mode_json=$(jq -r ".checks.debug" "$config_file")
    [ "$debug_mode_json" = "true" ] && debug_mode=1

    os_checks_json=$(jq -r ".checks.$MY_OS" "$config_file")
    if [ "$os_checks_json" != "null" ]; then
        os_checks_tsv=$(echo "$os_checks_json" | jq -r '. | @tsv')
        # if [ "$SHELL_NAME" = 'zsh' ]; then
        #     IFS=$'\t' read -r os_checks <<< "$os_checks_tsv"
        # else
        #     IFS=$'\t' read -ra os_checks <<< "$os_checks_tsv"
        # fi
        # split_string "$os_checks_tsv" $'\t'
        IFS=$'\t' read -ra SPLIT_STRING <<< "$os_checks_tsv"
        for check in ${SPLIT_STRING[@]+"${SPLIT_STRING[@]}"}; do
            checks+=("$check")
        done
    fi

    if [ "$MY_OS" != "win" ]; then 
        unix_checks_json=$(jq -r '.checks.unix' "$config_file")
        if [ "$unix_checks_json" != "null" ]; then
            unix_checks_tsv=$(echo "$unix_checks_json" | jq -r '. | @tsv')
            # debug "unix_checks_tsv: >$unix_checks_tsv<"
            # unix_checks=$(echo "$unix_checks" | jq -r '. | @sh' | sed 's/\\//g') # remove square brackets and escape slashes
            IFS=$'\t' read -ra SPLIT_STRING <<< "$unix_checks_tsv"
            for check in ${SPLIT_STRING[@]+"${SPLIT_STRING[@]}"}; do
                checks+=("$check")
            done
        fi
    fi

    if [ ${#checks[@]} -eq 0 ]; then
        [[ 'invoke_step_exit check_dependencies' =~ $calling_function ]] && return 0
        return 1
    fi

    # if [ "$step" = start_http_web ];then
    #     check_service http_server web && check_service http_server mongodb
    #     exit_status=$?
    #     TEST_ALL_PASSED=$exit_status
    # else
        for check in ${checks[@]+"${checks[@]}"}; do
        # for check in ${unix_checks[@]+"${unix_checks[@]}"}; do
        # for check in $unix_checks; do
            # check=$(echo "$check" | jq -r '. | .[]') # remove square brackets
            # eval "$check" ${args[*]+"${args[*]}"} >/dev/null
            # eval "$check ${args[*]+"${args[*]}"}" >/dev/null
            eval "$check" >/dev/null
            exit_status=$?

            if [ "$debug_mode" -eq 1 ]; then
                debug "Check: $check"
                debug "Result: $exit_status"
            fi

            if [ "$exit_status" -ne 0 ]; then
                if [ "$calling_function" = "invoke_step_exit" ]; then
                    warn "$step ${args[*]} step failed"
                    info "Check: $check"
                    info "Result: $exit_status"
                    show_help "$step"
                fi
                return 1
            fi
        done
    # fi

    return 0
}
