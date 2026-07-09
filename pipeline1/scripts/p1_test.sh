#!/usr/bin/env bash

if ! python3 -m pip list 2> /dev/null | grep -q pytest; then
    pip install pytest
fi

cd "$P1_ROOT_UNIX/pipeline1" || exit
python3 -m pytest
