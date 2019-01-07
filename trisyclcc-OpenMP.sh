#!/bin/bash

     #####################################################################
     #                                                                   #
     # Copyright (c) 2016 Paul Keir, University of the West of Scotland. #
     #                                                                   #
     #####################################################################

HOST_CXX=clang++-7

usage() { echo trisyclcc: error: $2 >&2; exit $1; }

[ $# -eq 0      ] && usage 1 "no input files"
[ -z "$TRISYCL" ] && usage 2 "create and initialise a TRISYCL environment var"

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
      $HOST_CXX -E -Wall -Wno-ignored-attributes -pthread $OPTS $CFLAGS $INCS $MACROS $DEBUG -O3 -std=c++17 -fopenmp -I$TRISYCL/include -o $OFILE $FILEPATH
    else
      $HOST_CXX -E -Wall -Wno-ignored-attributes -pthread $OPTS $CFLAGS $INCS $MACROS $DEBUG -O3 -std=c++17 -fopenmp -I$TRISYCL/include           $FILEPATH
    fi
    continue
  fi

  FILENAME=_`echo $FILEPATH | tr '//' '#'`  # prepend _ and replace /s with #s
  OBJFILES="$TMP/$FILENAME.o $OBJFILES"
  $HOST_CXX -Wall -Wno-ignored-attributes -pthread $OPTS $CFLAGS $INCS $MACROS $DEBUG -O3 -std=c++17 -fopenmp -I$TRISYCL/include -o $TMP/$FILENAME.o -c $FILEPATH
  # debug flags -ferror-limit=500
  # $HOST_CXX -Wall -Wno-ignored-attributes -pthread $OPTS $CFLAGS $INCS $MACROS $DEBUG -O3 -std=c++17 -D_OPENMP -DNDEBUG -DTRISYCL_DEBUG -DBOOST_LOG_DYN_LINK -I$TRISYCL/include -o $TMP/$FILENAME.o -c $FILEPATH
  # $HOST_CXX -Wall -Wno-ignored-attributes -S -emit-llvm -pthread $OPTS $CFLAGS $INCS $MACROS $DEBUG -std=c++17 -D_OPENMP -DNDEBUG -DTRISYCL_DEBUG -DBOOST_LOG_DYN_LINK -I$TRISYCL/include -o $FILENAME.llvm -c $FILEPATH

  if ((COMPILE_ONLY)); then            # Handle -c
    if ((OFILE_NAMED)); then
      cp $TMP/$FILENAME.o $OFILE
    else
      cp $TMP/$FILENAME.o $(basename "$FILEPATH" | cut -d. -f1).o
    fi
  fi
done

if ((!COMPILE_ONLY && !PREPROCESS_ONLY)); then
  $HOST_CXX -Wall -Wno-ignored-attributes -pthread $OBJFILES -o $OFILE -rdynamic $OPTS $CFLAGS $LIBPATHS -O3 -std=c++17 -fopenmp -I$TRISYCL/include $LDFLAGS
fi
