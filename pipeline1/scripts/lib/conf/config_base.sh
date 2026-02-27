#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

libraries=$(find "$P1_ROOT_SCRIPT/lib" -name 'detect_os.sh' -o -name 'get_shell_version.sh' -o -name 'get_wsl_win_info.sh')
for lib in $libraries; do
    source "$lib"
done

P1_VERSION='2.0'  # Update this when making changes that require users to update their profiles

get_shell_version
P1_USER_UNIX=''
P1_USER_WIN=''
WINDOP1_HOME=''
WORKING_DIR_WIN=''
VM=''

if [ -f /var/tmp/wsl-users.txt ]; then
    P1_USER_UNIX=$(cat /var/tmp/wsl-users.txt)
else
    P1_USER_UNIX=$(whoami)
    echo "$P1_USER_UNIX" > /var/tmp/wsl-users.txt
fi

BASE_DIR="$HOME/.pipeline1"
WORKING_DIR="$BASE_DIR/working"
LOG_BASE="$BASE_DIR/log"
MY_DOWNLOAD_DIR="$BASE_DIR/downloads"

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m' # No Color
if [ "$(locale charmap)" = 'UTF-8' ]; then
#   TICK_MARK='\0342\0234\0224'
    TICK_MARK='\U2714'
    CROSS_MARK='\U274C'
else
  TICK_MARK='[X]'
  CROSS_MARK='[-]'
fi

detect_os

[ "$VM" = 'wsl' ] && get_wsl_win_info


case $MY_OS in
ubuntu)
    source "$P1_ROOT_SCRIPT"/lib/conf/config_ubuntu.sh
    ;;
macos)
    source "$P1_ROOT_SCRIPT"/lib/conf/config_macos.sh
    ;;
*)
    echo "config_base: unsupported OS $MY_OS"
esac

# Todo: Project dependent configuration. Move these out of core.
ANDROID_EMULATOR_PORT=5554
LOGINENV=sandpit

NODE_MAJOR_VERSION=22
DOTNET_MAJOR_VERSION=8
PYTHON_MAJOR_VERSION=3.10
GNUPG_VERSION=2.4.8
LIBGPG_ERROR_VERSION=1.56
LIBKSBA_VERSION=1.6.7
