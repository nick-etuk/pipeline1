#!/usr/bin/env bash

function show_menu_advanced {

read -r -d '' ADVANCED_MENU << EOM
    1 Run individual step
    2 Rebuild backend
EOM

read -r -d '' ADVANCED_EXTRAS << EOM
    M Main menu
    H Help

    Q Quit
EOM

    local empty 
    local option
    local service
    
    option=""

    clear
    printf "\n\nAdvanced\n"
    printf "\n    %s\n" "$ADVANCED_MENU"
    printf "\n    %s\n\n" "$ADVANCED_EXTRAS"

    read -rp "[M]: " option
    case $option in
        1) 
            read -rp "Step: " step
            eval "$step"
            ;;
        2)
            service=$(show_menu_rebuild)

            start_docker
            docker_login

            if [ "$service" = all ]; then
                services=(backendworker web android bddtests xamarinintegrationtests)
                for item in "${services[@]}"; do
                    FORCE=1 build_backend "$item"
                done
            else
                FORCE=1 build_backend "$service"
            fi
            ;;
 
        M|m) show_menu_main ;;
        H|h) do_help ;;
        Q|q) do_quit ;;
        *) 
            show_menu_main
			;;
        
    esac
}
