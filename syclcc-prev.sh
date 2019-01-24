#!/bin/bash

not_sourced() { [[ "${FUNCNAME[1]}" != source ]] && return 0 || return 1; }

if not_sourced; then
  echo "error: invoke this script using \"source\""
  exit 255
fi

[ -z "$COMPUTECPP_DIR" ] && usage 2 "create and initialise a COMPUTECPP_DIR environment var"

RELEASES=(
"ComputeCpp-15.10-Linux"
"ComputeCpp-16.03-Linux"
"ComputeCpp-16.05-Linux"
"ComputeCpp-CE-0.1-Linux"
"ComputeCpp-CE-0.2.0-Linux"
"ComputeCpp-CE-0.2.1-Linux"
"ComputeCpp-CE-0.3.0-Linux"
"ComputeCpp-CE-0.3.1-Linux"
"ComputeCpp-CE-0.3.2-Linux"
"ComputeCpp-CE-0.3.3-Ubuntu.16.04-64bit"
"ComputeCpp-CE-0.4.0-Ubuntu-16.04-64bit"
"ComputeCpp-CE-0.5.0-Ubuntu-16.04-64bit"
"ComputeCpp-CE-0.5.1-Ubuntu-16.04-64bit"
"ComputeCpp-CE-0.6.0-Ubuntu-16.04-64bit"
"ComputeCpp-CE-0.6.1-Ubuntu-16.04-64bit"
"ComputeCpp-CE-0.7.0-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-0.8.0-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-0.9.0-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-0.9.1-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.0-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.1-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.2-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.3-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.4-Ubuntu-16.04-x86_64"
)
NUM_RELEASES=${#RELEASES[@]}

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

COMPUTECPP_DIR_BASENAME=`basename "$COMPUTECPP_DIR"`
COMPUTECPP_DIR_DIRNAME=`dirname "$COMPUTECPP_DIR"`

INDEX=$(array_find "$COMPUTECPP_DIR_BASENAME" "${RELEASES[@]}")

# Decrement INDEX - else if it's the first index - set it to N-1
#[[ $INDEX < $((NUM_RELEASES-1)) ]] && INDEX=$((INDEX+1)) || INDEX=0
[[ $INDEX == 0 ]] && INDEX=$((NUM_RELEASES-1)) || INDEX=$((INDEX-1))

NEWCOMPUTECPP_DIR="$COMPUTECPP_DIR_DIRNAME"/"${RELEASES[INDEX]}"

COMPUTECPP_DIR=$NEWCOMPUTECPP_DIR
LD_LIBRARY_PATH=$COMPUTECPP_DIR/lib:$LD_LIBRARY_PATH
echo COMPUTECPP_DIR now set to $NEWCOMPUTECPP_DIR
