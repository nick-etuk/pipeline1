# shellcheck shell=sh
# shellcheck disable=SC2034,SC1091

detect_os() {
	# local os_name
	
	os_name=$(uname -a)
    case "$os_name" in
        *microsoft*)
            MY_OS='ubuntu'
            VM='wsl'
            return
            ;;
    esac

    VM=''

    os_name=$(uname -s)

    # [ "$SHELL_NAME" = 'zsh' ] && shopt -s nocasematch
    case "$os_name" in
        darwin|Darwin)
            MY_OS='macos'
            ;;
        linux|Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    *ubuntu*)
                        MY_OS='ubuntu'
                        ;;
                    *debian*)
                        MY_OS='debian'
                        ;;
                esac
            fi
            ;;
        cygwin*|mingw32*|msys*|mingw*)
            MY_OS='win'
            ;;
        *)
            echo "detect_os: unsupported OS $os_name"
            ;;
    esac
}
