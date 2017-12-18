#!/bin/bash

not_sourced() { [[ "${FUNCNAME[1]}" != source ]] && return 0 || return 1; }

if not_sourced; then
  echo "error: invoke this script using \"source\""
  exit 255
fi

[ -z "$COMPUTECPP" ] && usage 2 "create and initialise a COMPUTECPP environment var"

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

COMPUTECPP_BASENAME=`basename "$COMPUTECPP"`
COMPUTECPP_DIRNAME=`dirname "$COMPUTECPP"`

INDEX=$(array_find "$COMPUTECPP_BASENAME" "${RELEASES[@]}")

# Set the INDEX to 0 if it's the final index - else increment Index
[[ $INDEX == $((NUM_RELEASES - 1)) ]] && INDEX=0 || INDEX=$((INDEX+1))

NEWCOMPUTECPP="$COMPUTECPP_DIRNAME"/"${RELEASES[INDEX]}"

COMPUTECPP=$NEWCOMPUTECPP
LD_LIBRARY_PATH=$COMPUTECPP/lib:$LD_LIBRARY_PATH
echo COMPUTECPP now set to $NEWCOMPUTECPP
