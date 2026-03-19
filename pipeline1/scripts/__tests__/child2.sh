#!/usr/bin/env bash

echo "Hello from child2"
echo -n "arguments:"
args=( "$@" )
for arg in "${args[@]}"; do echo -n "$arg " ; done
echo
