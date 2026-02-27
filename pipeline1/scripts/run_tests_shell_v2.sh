#!/usr/bin/env bash

function run_tests {
    local tests

    tests=("$@")

    for test in "${tests[@]}"; do
        info "============================="
        info "Running test: $test"
        info "============================="
        EXPECTED=''
        ACTUAL=''
        eval "$test"
        exit_status=$?
        if [ "$exit_status" -eq 0 ] && [ "${ACTUAL[*]+"${ACTUAL[*]}"}" = "${EXPECTED[*]+"${EXPECTED[*]}"}" ]; then
            # echo -e "${GREEN}$test ${TICK_MARK}${NC}"
            echo -e "$test ${TICK_MARK}"
        else
            echo -e "$test ${CROSS_MARK}"
            echo "${EXPECTED[*]+"${EXPECTED[*]}"}" > "$WORKING_DIR/test_results/${test}_expected.txt"
            echo "${ACTUAL[*]+"${ACTUAL[*]}"}" > "$WORKING_DIR/test_results/${test}_actual.txt"
            diff "$WORKING_DIR/test_results/${test}_expected.txt" "$WORKING_DIR/test_results/${test}_actual.txt"
        fi
    done
}

