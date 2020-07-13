#!/bin/bash

   ##########################################################################
   #                                                                        #
   #   Copyright (c) 2019 Paul Keir, University of the West of Scotland.    #
   #                                                                        #
   ##########################################################################

usage() { echo bsyclcc: error: $2 >&2; exit $1; }

[ $# -eq 0      ] && usage 1 "no input files"
[ -z "$COMPUTECPP_DIR" ] && usage 2 "create and initialise a COMPUTECPP_DIR environment var"

COMPILE_ONLY=0
PREPROCESS_ONLY=0
USE_HOST=0

# Options are the same as the -sycl-target's argument: e.g. spir64/spirv64/ptx64
USE_BACKEND=$SYCLCC_COMPUTECPP_BACKEND

if [[ -z "$HOST_CXX" ]]; then
  HOST_CXX=/usr/bin/g++
fi

if [[ -z "$SYCLCC_COMPUTECPP_BACKEND" ]]; then
  USE_BACKEND=spir64
fi

while [[ $# > 0 ]]; do
  case "$1" in
    -E)   PREPROCESS_ONLY=1; CMD="$CMD $1" ;;
    -c)      COMPILE_ONLY=1; CMD="$CMD $1" ;;
    -syclcc-use-host) USE_HOST=1; CMD="$CMD" ;;
    *)                       CMD="$CMD $1" ;;
  esac
  shift # $2 becomes $1; $3 becomes $2 etc.
done

if ((!USE_HOST)); then
  if ((!COMPILE_ONLY && !PREPROCESS_ONLY)); then CMD="$CMD -L $COMPUTECPP_DIR/lib -lComputeCpp"; fi

  $COMPUTECPP_DIR/bin/compute++ -O2 -mllvm -inline-threshold=1000 -Wno-unused-command-line-argument -sycl-driver -sycl-target $USE_BACKEND -no-serial-memop -I $COMPUTECPP_DIR/include -std=c++11 $CMD
else
  $HOST_CXX $CMD
fi

exit $?
