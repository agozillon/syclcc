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
)

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
for SCRIPTPATH in "$SCRIPTDIR"/syclcc-ComputeCpp*Ubuntu-16.04-x86_64.sh
do
  BN=("$(basename "$SCRIPTPATH")") # Drop the base part of the sh filepath
  RELEASES+=(${BN:7:39})           # Select 39 chars start at char 
done

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

# Set the INDEX to 0 if it's the final index - else increment Index
[[ $INDEX == $((NUM_RELEASES - 1)) ]] && INDEX=0 || INDEX=$((INDEX+1))

NEWCOMPUTECPP_DIR="$COMPUTECPP_DIR_DIRNAME"/"${RELEASES[INDEX]}"

COMPUTECPP_DIR=$NEWCOMPUTECPP_DIR
LD_LIBRARY_PATH=$COMPUTECPP_DIR/lib:$LD_LIBRARY_PATH
echo COMPUTECPP_DIR now set to $NEWCOMPUTECPP_DIR
