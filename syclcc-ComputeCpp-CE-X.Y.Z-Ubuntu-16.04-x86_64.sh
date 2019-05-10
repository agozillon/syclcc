#!/bin/bash

   ##########################################################################
   #                                                                        #
   # Copyright (c) 2016-2019 Paul Keir, University of the West of Scotland. #
   #                                                                        #
   ##########################################################################

HOST_CXX=/usr/bin/g++    # Don't use $CXX as $CXX may reference this script.

usage() { echo syclcc: error: $2 >&2; exit $1; }

[ $# -eq 0      ] && usage 1 "no input files"
[ -z "$COMPUTECPP_DIR" ] && usage 2 "create and initialise a COMPUTECPP_DIR environment var"
  
COMPILE_ONLY=0
PREPROCESS_ONLY=0
OFILE="a.out"
while [[ $# > 0 ]]; do

  case "$1" in
    -I)       INCS="$INCS $1$2";     shift ;;
    -D)     MACROS="$MACROS $1$2";   shift ;;
    -L)   LIBPATHS="$LIBPATHS $1$2"; shift ;;
    -l)    LDFLAGS="$LDFLAGS $1$2"   shift ;;
    -isystem) INCS="$INCS $1$2";     shift ;;
    -o) OFILE=$2; OFILE_NAMED=1;     shift ;;
    -I?*)         INCS="$INCS $1"          ;; # no space between; no shift
    -D?*)       MACROS="$MACROS $1";       ;;
    -L?*)     LIBPATHS="$LIBPATHS $1";     ;;
    -l?*)      LDFLAGS="$LDFLAGS $1"       ;;
    -O?*)         OPTS="$OPTS $1";         ;; # e.g. -O3
    -f?*)       CFLAGS="$CFLAGS $1"        ;; # consider ;& for some code golf
    -v)         CFLAGS="$CFLAGS $1"        ;;
    -dM)        CFLAGS="$CFLAGS $1"        ;;
    -E) PREPROCESS_ONLY=1                  ;; # stop after preprocessing stage
    -g)          DEBUG="$1"                ;; # still doesn't work with CE 0.5
    -std=?*)    CFLAGS="$CFLAGS $1"        ;;
    -rdynamic) LDFLAGS="$LDFLAGS $1"       ;;
    -o?*) OFILE=${1:2}; OFILE_NAMED=1;     ;; # "-o" = the 2 dropped chars
    -c)   COMPILE_ONLY=1                   ;;
    -*)   usage -1 "flags: $1"             ;;
    *)    FILEPATHS="$1   $FILEPATHS"      ;;
  esac
  shift # $2 becomes $1; $3 becomes $2 etc.
done

if ((COMPILE_ONLY && OFILE_NAMED)) && [ $# -gt 1 ] ; then
  usage 3 "cannot specify -o with -c, with multiple files"
fi

TMP=`mktemp -d`

for FILEPATH in $FILEPATHS
do
  EXT=${FILEPATH##*.}    # Skip object/lib files; though do collect their names
  if [[ $EXT != @(h|c|i|ii|cc|cp|cxx|cpp|c++|C|hh|hp|hxx|hpp|h++|H) ]]; then
    OBJFILES="$FILEPATH $OBJFILES"   # Reverse this to match gcc/clang?
    continue
  fi

  if ((PREPROCESS_ONLY)); then      # Handle -E
    if ((OFILE_NAMED)); then
      $HOST_CXX -E -DBUILD_PLATFORM_SPIR -I$COMPUTECPP_DIR/include $OPTS $CFLAGS $INCS $MACROS -std=c++1z -pthread -o $OFILE $FILEPATH
    else
      $HOST_CXX -E -DBUILD_PLATFORM_SPIR -I$COMPUTECPP_DIR/include $OPTS $CFLAGS $INCS $MACROS -std=c++1z -pthread           $FILEPATH
    fi
    continue
  fi

  FILENAME=_`echo $FILEPATH | tr '//' '#'`  # prepend _ and replace /s with #s
  OBJFILES="$TMP/$FILENAME.o $OBJFILES"
  $COMPUTECPP_DIR/bin/compute++ -std=c++11 -no-serial-memop $OPTS -O2 -sycl -emit-llvm -I$COMPUTECPP_DIR/include $CFLAGS $INCS $MACROS -o $TMP/$FILENAME.bc -c $FILEPATH
 # $COMPUTECPP_DIR/bin/compute++ -std=c++0x $OPTS -O2 -sycl -emit-llvm -I$COMPUTECPP_DIR/include $CFLAGS $INCS $MACROS -o $TMP/$FILENAME.bc -c $FILEPATH

  INCFLAG="-include $TMP/$FILENAME.sycl"
  $HOST_CXX -DBUILD_PLATFORM_SPIR -I$COMPUTECPP_DIR/include -I$TMP $OPTS -O2 $DEBUG $CFLAGS $INCS $MACROS $INCFLAG -std=c++1z -pthread -o $TMP/$FILENAME.o -c $FILEPATH

  if ((COMPILE_ONLY)); then            # Handle -c
    if ((OFILE_NAMED)); then
      cp $TMP/$FILENAME.o $OFILE
    else
      cp $TMP/$FILENAME.o $(basename "$FILEPATH" | cut -d. -f1).o
    fi
  fi
done

if ((!COMPILE_ONLY && !PREPROCESS_ONLY)); then
  $HOST_CXX -std=c++1z -pthread $OBJFILES -o $OFILE -rdynamic $OPTS -O2 $DEBUG $CFLAGS $LIBPATHS -L$COMPUTECPP_DIR/lib/ -lComputeCpp -lOpenCL $LDFLAGS
fi
