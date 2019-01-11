#!/bin/bash

#########################################################################################
#                                                                                       #
# Copyright (c) 2019 Andrew Gozillon and Paul Keir, University of the West of Scotland. #
#                                                                                       #
#########################################################################################

not_sourced() { [[ "${FUNCNAME[1]}" != source ]] && return 0 || return 1; }

if not_sourced; then
  echo "error: invoke this script using \"source\""
  exit 255
fi

[ -z "$TRISYCL_TARGET" ] && usage 2 "create and initialise a TRISYCL_TARGET environment var"

TARGETS=(
"OpenMP"
"OpenCL"
"sw_emu"
"hw_emu"
)
NUM_TARGETS=${#TARGETS[@]}

array_find() {
  local i=0
  local e match="$1"
  shift
  for e; do
    if [[ "$e" == "$match" ]]; then
      echo $i      # match found
      return 0
    else
      i=$((i+1))
    fi
  done
  return 255       # no match found
}

INDEX=$(array_find "$TRISYCL_TARGET" "${TARGETS[@]}")

# Decrement INDEX - else if it's the first index - set it to N-1
#[[ $INDEX < $((NUM_TARGETS-1)) ]] && INDEX=$((INDEX+1)) || INDEX=0
[[ $INDEX == 0 ]] && INDEX=$((NUM_TARGETS-1)) || INDEX=$((INDEX-1))

TRISYCL_TARGET="${TARGETS[INDEX]}"

echo TRISYCL_TARGET now set to $TRISYCL_TARGET
