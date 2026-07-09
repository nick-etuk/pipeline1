#!/usr/bin/env bash

if ! python3 -m pip list 2> /dev/null | grep -q pylint; then
    pip install pylint
fi

cd "$P1_ROOT_UNIX/pipeline1" || exit
python3 -m pylint pipeline1
