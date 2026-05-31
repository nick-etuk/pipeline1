#!/usr/bin/env bash

function iam_elevated {
    [ $EUID -eq 0 ] || return 1
}
