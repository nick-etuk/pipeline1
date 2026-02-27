#!/usr/bin/env bash

cd "$P1_ROOT_UNIX"/pipeline1 || exit 1
python -m unittest
