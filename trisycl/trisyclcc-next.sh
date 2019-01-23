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
"TBB"
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

# Set the INDEX to 0 if it's the final index - else increment Index
[[ $INDEX == $((NUM_TARGETS - 1)) ]] && INDEX=0 || INDEX=$((INDEX+1))

TRISYCL_TARGET="${TARGETS[INDEX]}"

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$TRISYCL_TARGET" = "OpenCL" ] ; then
  source $SCRIPT_PATH/set_environment_scripts/pocl.sh
fi

# Just sets some BOOST Compute enviornment variables back to nothing
if [ "$TRISYCL_TARGET" = "OpenMP" ] || [ "$TRISYCL_TARGET" = "TBB" ]; then
  source $SCRIPT_PATH/set_environment_scripts/reset.sh
fi

echo TRISYCL_TARGET now set to $TRISYCL_TARGET
