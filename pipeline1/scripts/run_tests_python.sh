#!/usr/bin/env bash
pip install pytest
cd "$P1_ROOT_UNIX/pipeline1" || exit
python -m pytest
