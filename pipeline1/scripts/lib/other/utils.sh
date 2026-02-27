#!/usr/bin/env bash

function join {
  local d=${1-} 
  local f=${2-}

  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

function replace_v1 {
    local string
    local old
    local new

    string=$1
    old=$2
    new=$3

    echo "${string//old/new}"
}

function replace_v2 {
    local string
    local old
    local new

    string=$1
    old=$2
    new=$3

    echo "$string" | sed "s/$old/$new/g"
}

replace() { replace_v2 "$1" "$2" "$3"; }