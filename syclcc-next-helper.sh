#!/bin/bash

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
"ComputeCpp-CE-1.0.2-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.3-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.4-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.0.5-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.1.0-Ubuntu-16.04-x86_64" 
"ComputeCpp-CE-1.1.1-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.1.2-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.1.3-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.1.4-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.1.5-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.1.6-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.2.0-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-1.3.0-Ubuntu-16.04-x86_64"
"ComputeCpp-CE-2.0.0-x86_64-linux-gnu"
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

if [[ $1 == "NEXT" ]]; then
  # Set the INDEX to 0 if it's the final index - else increment Index
  [[ $INDEX == $((NUM_RELEASES - 1)) ]] && INDEX=0 || INDEX=$((INDEX+1))
else
  # Decrement INDEX - else if it's the first index - set it to N-1
  [[ $INDEX == 0 ]] && INDEX=$((NUM_RELEASES-1)) || INDEX=$((INDEX-1))
fi

NEWCOMPUTECPP_DIR="$COMPUTECPP_DIR_DIRNAME"/"${RELEASES[INDEX]}"

COMPUTECPP_DIR=$NEWCOMPUTECPP_DIR
LD_LIBRARY_PATH=$COMPUTECPP_DIR/lib:$LD_LIBRARY_PATH
echo COMPUTECPP_DIR now set to $NEWCOMPUTECPP_DIR
