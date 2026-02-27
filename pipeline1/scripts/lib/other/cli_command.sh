#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1091


cli_command() {
    local start=1
    local build=1
    local activity_id_list
    local step_script
    local service
    local command
    local activity_id
    local option_num
    local activity_args
    local step_args
    local args
    local project_activity_id
    local step
    local change_dir=1
    local script_file
    local script_dir
    
    if [ -z ${1+empty_string} ];then
        error "No CLI command provided"
    fi

    command=$1
    shift
    args=("$@")
    arg_count=$#
    info "CLI command $command ${args[*]+"${args[*]}"}"

    case "$command" in
        -h|--help)
            show_usage
            exit 0
        ;;
        -v|--version)
            show_version
            exit 0
        ;;
        -b|--build)
            build=0
            shift
        ;;
        get)
            if [ "$arg_count" -lt 1 ]; then
                error "Usage: get <key>"
                exit 1
            fi
            info "${args[*]} is set to $(get_config "${args[@]}")"
            exit 0
        ;;
        set)
            if [ "$arg_count" -lt 2 ]; then
                error "Usage: set <key> <value>"
                exit 1
            fi
            set_config "${args[@]}"
            info "${args[0]} set to ${args[*]:1}"
            exit 0
        ;;
        list)
            list_steps
            exit 0
        ;;
        update)
            update_activity_registry
            update_step_registry
            info "Activity and step registries updated"
            exit 0
        ;;
    esac

    step_config_file=$(get_step_path "$command")
    if [ -f "$step_config_file" ]; then
        step=$command
        run_step "$step" ${args[@]+"${args[@]}"}
        exit 0
    fi

    activity_registry="$WORKING_DIR/activity_registry.csv"
    if grep -q "^\"$command\"," "$activity_registry"; then
        info "Running activity $command"
        activity_id=$command
        CURRENT_PROJECT=$(get_config 'activity_id_project' "$activity_id") #todo: what is this for? activity ids are unique across all projects.
        set_config 'current_project' "$CURRENT_PROJECT"
        set_config 'current_activity' "$activity_id"
        run_activity "$activity_id" "${args[@]+"${args[@]}"}"
        exit 0
    fi
    info "$command is not a step or an activity"
    return 1
    # All reason ends here

    # Check if first argument is a menu option number
    if [ "$arg_count" -eq 1 ]; then
        start=0
        option_num="$1"
        args=("$@")
        activity_args=("${args[@]:1}")
    else
        args=("$@")
        activity_args=("${args[@]:2}")
        # build or start options provided
        while getopts ":hs:b:" opt; do
            case ${opt} in
                h )
                    show_usage
                    exit 0
                ;;
                s )
                    start=0
                    option_num=$OPTARG
                ;;
                b )
                    build=0
                    option_num=$OPTARG
                ;;
                \? )
                    warn "Invalid option $opt"
                    show_usage
                    exit 0
                    ;;

            esac
        done
    fi

    if [ -z ${option_num+empty_string} ];then
        error "No option number argument provided"
    fi

    # Build option provided. Prepare to build...
    case ${option_num} in
        1|web) 
            service=backendworker
        ;;
        2|dotnet) 
            service=backendworker
            ;;
        3|and) 
            service=android
            ;;
        4|bdd) 
            service=bddtests
            ;;
        5|xit) 
            service=xamarinintegrationtests
            ;;
        6|ios) 
            service=backendworker
            ;;
        *)
            warn "Invalid toolset $option_num"
            show_usage
            exit 0
            ;;
    esac

    if [ "$build" -eq 0 ]; then
        run_step start_docker
        run_step docker_login
        FORCE=1
        run_step build_backend "$service"
        FORCE=0
    fi

    if [ "$start" -eq 0 ]; then
        # debug "option_num: $option_num"
        project_activity_id=$(get_config 'activity_id' "$option_num")
        [ -z "$project_activity_id" ] && error "Unknown menu option $option_num"
        split_string "$project_activity_id" "."
        CURRENT_PROJECT="${SPLIT_STRING[0]}"
        [ "$SHELL_NAME" = 'zsh' ] && CURRENT_PROJECT="${SPLIT_STRING[1]}"
        set_config 'current_project' "$CURRENT_PROJECT"
        activity_id="${SPLIT_STRING[1]}"
        [ "$SHELL_NAME" = 'zsh' ] && activity_id="${SPLIT_STRING[2]}"
        set_config 'current_activity' "$activity_id"
        run_activity "$activity_id" "${activity_args[@]+"${activity_args[@]}"}"
    fi

}

