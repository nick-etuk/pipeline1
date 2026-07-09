#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1091,SC1090

if [ -z "$INIT_UNIX" ]; then
    # script_dir=$(dirname "$(realpath "$0")")
    # cd "$script_dir/.." || exit
    # . ./init.sh || exit 1
    init_script=$(find "$P1_ROOT_UNIX" -name "init.sh" -type f)
    . "$init_script" || exit 1
fi

# test_scripts=$(find "$P1_ROOT_UNIX" -name "*.test.sh" -name "test_*.sh" -type f)
test_scripts=$(find "$P1_ROOT_UNIX" -name 'test_*.sh' -type f)
for test_script in $test_scripts; do
    source "$test_script"
done

run_tests "$@"
