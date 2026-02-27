#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1090,SC1091

# When you use set -u, as we do (see init.sh),
# in bash 4.4 or below (macos currently has bash 3.2), 
# "${arr[@]}" causes an error if the array is empty
# so we have to use ${arr[@]+"${arr[@]}"}


run_step() {
    local parent_step_id
    local arg_count
    local fomatted_args
    local commands_json
    local status
    local original_step_id
    local step_dir
    local step_script
    local step_config
    local parallel='false'
    local prompt
    local args
    local child_steps
    local step_os_json
    local step_commands
    local all_passed
    local child_args
    local arg
    local run_once
    local run_always='false'

    empty_string=''
    if [ -z ${1+empty_string} ];then
        error "No step argument provided"
    fi

    parent_step_id=$1

    CURRENT_STEP=$parent_step_id # used for logging
    shift
    args=("$@")
    arg_count=$#
    if [ $arg_count -gt 0 ]; then
        debug "step $parent_step_id with arguments: ${args[*]+"${args[*]}"}"
    # else
        # debug "step $parent_step_id"
    fi
    # This script may be called directly, outside p1.sh,
    # so we need to set P1_ROOT_UNIX and source init.sh if 
    # these things have not already been done
    if [ -z ${P1_ROOT_UNIX+empty_string} ];then
        SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
        P1_ROOT_UNIX=$( cd -- "$( dirname -- "${SCRIPT_PATH}/../.." )" &> /dev/null && pwd )
        echo "Run step setting P1_ROOT_UNIX to $P1_ROOT_UNIX"
        cd "$P1_ROOT_UNIX" || exit 1
    fi
    [ -z "${INIT_UNIX+empty_string}" ] && source "$P1_ROOT_UNIX/core/init.sh"

    step_config=$(get_step_path "$parent_step_id")
    if [ ! -f "$step_config" ]; then
        warn "No configuration file for $parent_step_id"
        return 1
    fi

    step_os_json=$(jq -r '.os' "$step_config")
    if ! correct_os "$step_os_json"; then
        info "Skipping $parent_step_id: not for $MY_OS"
        return 0
    fi
        
    run_once=$(jq -r '.runOnce' "$step_config")
    if [ "$run_once" = 'true' ];then
        key="step_$parent_step_id"

        if [ "$arg_count" -gt 0 ]; then
            fomatted_args=$(join '_' ${args[@]+"${args[@]}"})
            key="step_${parent_step_id}_$fomatted_args"
        fi

        status=$(get_config status "$key")

        if [ "$status" = 'done' ]; then
            info "$(get_step_description "$parent_step_id") step already done"
            return 0
        fi
    fi

    run_always=$(jq -r '.runAlways' "$step_config")
    if [ "$run_always" != 'true' ];then
        invoke_step_entry -s "$parent_step_id" ${args[@]+"${args[@]}"} || return 0
    fi

    if [ "$NEW_TAB" = 'true' ]; then
        debug "run_step: NEW_TAB is true"
        parallel='false'
    else
        parallel=$(jq -r '.parallel' "$step_config")
    fi
    
    all_passed=0

    commands_json=$(jq '.commands' "$step_config")
    if [ "$commands_json" != 'null' ]; then
        # step_commands=$(echo "$commands_json" | jq -r '.| .[]')
        # debug "step_commands: >$step_commands<"
        # [ "$SHELL_NAME" = 'zsh' ] && error "step_commands: Zsh is not supported for this function. Please use Bash."
        # for command in $step_commands; do
        #     debug "command: >$command<"
        #     eval "$command" >/dev/null
        # done
        commands_tsv=$(echo "$commands_json" | jq -r '. | @tsv')
        debug "commands_tsv: >$commands_tsv<"
        IFS=$'\t' read -ra SPLIT_STRING <<< "$commands_tsv"
        for command in ${SPLIT_STRING[@]+"${SPLIT_STRING[@]}"}; do
            debug "command: >$command<"
            if [ "$parallel" = 'true' ]; then
                new_tab "$command"
            else
                eval "$command"
            fi
        done
    fi

    child_steps=$(jq '.steps' "$step_config")
    if [ "$child_steps" != 'null' ]; then
        child_steps=$(echo "$child_steps" | jq -r '.| .[]')
        [ "$SHELL_NAME" = 'zsh' ] && error "child_steps: Zsh is not supported for this function. Please use Bash."
        for child in $child_steps; do
            child_args=()
            IFS=' ' read -ra split_string <<< "$child"
            for arg in "${split_string[@]}"; do 
                [[ ! "$arg" == *\$\@* ]] && child_args+=("$arg");
            done

            # if [[ "$child" == *~* ]]; then
            if [[ "$child" == *\$\@* ]]; then
                debug "Propagating parent arguments ${args[*]+"${args[*]}"} to ${split_string[0]}"
                for arg in ${args[@]+"${args[@]}"}; do 
                    # [[ ! "$arg" == *~* ]] && child_args+=("$arg"); 
                    [[ ! "$arg" == *\$\@* ]] && child_args+=("$arg"); 
                done
            fi

            if ! run_step "${child_args[@]}"; then
            # if [ $? -ne 0 ]; then
                info "Child step $(get_step_description "$child") step failed"
                all_passed=1
            fi
        done
    fi
    
    prompt=$(jq -r '.prompt' "$step_config")
    if [ "$prompt" != 'null' ]; then
        # read -p "$prompt" -n 1 -r
        read -rp "$prompt [y], later [l] or never[n]" answer
        [ ! "$answer" = 'y' ] && return
    fi
    
    step_dir="$(dirname -- "$step_config")"
    step_script="$step_dir/$parent_step_id.sh"
    original_step_id=$parent_step_id
    if [ -f "$step_script" ]; then
        # if [ "$original_step_id" != 'start_service' ]; then 
            if [ "$parallel" = 'true' ]; then
                # startup_script=$(find "$P1_ROOT_UNIX/core" -name "p1.sh" -type f)
                info "$original_step_id parallel step started"
                debug "args: $original_step_id ${args[*]+"${args[*]}"}"
                # new_tab "$startup_script" "$original_step_id" "$@"
                # new_tab "$startup_script $original_step_id ${args[*]+"${args[*]}"}"
                new_tab "$original_step_id ${args[*]+"${args[*]}"}"
            else
                info "$original_step_id step started"
                # source "$step_script" ${args[@]+"${args[@]}"}
                source "$step_script" "$@"
            fi
        # fi
    # else
        # warn "No script found for step $original_step_id in $step_dir"
        # debug "step_script: $step_script"
    fi

    if [ "$parent_step_id" != "$original_step_id" ]; then
        warn "Step id has changed to $parent_step_id. Should be $original_step_id"
        parent_step_id="$original_step_id"
    fi

    # if ! invoke_step_exit -p "$parallel" -s "$parent_step_id" ${args[@]+"${args[@]}"}; then
    if [ "$run_always" != 'true' ];then
        if ! invoke_step_exit -p "$parallel" -s "$parent_step_id" "$@"; then
            all_passed=1
        fi
    fi
    # [ "$parent_step_id" = 'start_service' ] && exit 0

    if [ $all_passed -eq 0 ]; then
        if [ "$NEW_TAB" = 'true' ] && [[ 'start_service build_backend' == *$parent_step_id* ]]; then
            info "$(get_step_description "$parent_step_id") step completed in new tab"
        else
            info "$(get_step_description "$parent_step_id") step completed"
        fi
        
        [ "$run_once" = 'true' ] && set_config status "$key" 'done'
    fi
    return $all_passed
}
