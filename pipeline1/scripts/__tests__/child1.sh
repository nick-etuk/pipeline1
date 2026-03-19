#!/usr/bin/env bash

echo "Hello from child1"
echo -n "arguments:"
args=( "$@" )
for arg in "${args[@]}"; do echo -n "$arg " ; done
echo
