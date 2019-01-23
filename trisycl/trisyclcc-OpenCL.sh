#!/bin/bash

#########################################################################################
#                                                                                       #
# Copyright (c) 2019 Andrew Gozillon and Paul Keir, University of the West of Scotland. #
#                                                                                       #
#########################################################################################

# Heavily based on the triSYCL tests/Makefile but cut down to required steps for
# OpenCL compilation.
usage() { echo trisyclcc: error: $2 >&2; exit $1; }

# no need to use .kernel_caller convention for passed in files, just use .cpp
# etc.
[ $# -eq 0      ] && usage 1 "no input files"
# [ -z "$TRISYCL_DIR" ] && usage 1 "create and initialise a TRISYCL_DIR \
#    environment var"
#
# # For OpenCL compilation you are required to have the triSYCL device compiler
# # more information on this can be found at: https://github.com/triSYCL
# # The DEVICE_COMPILER_DIR should be set to something that contains the
# # device compilers clang++ and opt programs (for example the build/bin directory
# # of the Clang/LLVM after compilation)
# [ -z "$DEVICE_COMPILER_DIR" ] && usage 1 "create and initialise a \
#    DEVICE_COMPILER_DIR environment var"
#
# # Sadly can't export these as the syclcc scripts are not normally invoked using
# # source or ., I can point them in the right direction of the setup scripts for
# # each though when its not set. They are set when prev/next is called however.
# [ -z "$BOOST_COMPUTE_DEFAULT_ENFORCE" ] && usage 1 "invoke the pocl.sh script \
#   using source or create environment variable: BOOST_COMPUTE_DEFAULT_ENFORCE, \
#   with value 1"
# [ -z "$BOOST_COMPUTE_DEFAULT_PLATFORM" ] && usage 1 "invoke the pocl.sh script \
#   using source or create environment variable: BOOST_COMPUTE_DEFAULT_PLATFORM, \
#   with value 'Portable Computing Language'"

# it's possible to use another Clang compiler as the host/final link compiler,
# but I would advise using the same compiler as the device compiler to avoid
# LLVM IR incompatabilities from different versions of Clang/LLVM
HOST_CXX=$DEVICE_COMPILER_DIR/bin/clang++
CL_CXX=$DEVICE_COMPILER_DIR/bin/clang++

# Has to be from the triSYCL device compiler as it has triSYCL specific passes
CL_OPT=$DEVICE_COMPILER_DIR/bin/opt

COMPILE_ONLY=0
PREPROCESS_ONLY=0
OFILE="a.out"
while [[ $# > 0 ]]; do
# Perhaps add the option to specify -j to the script as it's a very slow build process.
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
    -g)          DEBUG="$1"                ;; # this will kill the triSYCL device compiler
    -std=?*)    CFLAGS="$CFLAGS $1"        ;;
    -rdynamic) LDFLAGS="$LDFLAGS $1"       ;;
    -o?*) OFILE=${1:2}; OFILE_NAMED=1;     ;; # "-o" = the 2 dropped chars
    -c)   COMPILE_ONLY=1                   ;;
    -*)   usage -1 "flags: $1"             ;;
    *)    FILEPATHS="$1   $FILEPATHS"      ;;
  esac
  shift # $2 becomes $1; $3 becomes $2 etc.
done

# triSYCL related CFLAGs and includes, the DTRISYCL_USE_OPENCL_ND_RANGE enables
# a true parallel_for call rather than mimicing it through single_tasks,
#see triSYCL readme for more information.
# Note: Has to be compiled with -O3 for the moment, triSYCL device compiler
# needs very clean code to work with. I also ignore all warnings as triSYCL has
# a large amount of warnings at the time of creation of this script.
CFLAGS="-DTRISYCL_OPENCL -O3 -DNDEBUG -DTRISYCL_DEBUG -DBOOST_LOG_DYN_LINK \
        -Wall -Wno-ignored-attributes -Wno-everything -std=c++17 \
        -I$TRISYCL_DIR/include -DTRISYCL_USE_OPENCL_ND_RANGE $CFLAGS"

# triSYCL boost CFLAGs
CFLAGS="-DBOOST_COMPUTE_HAVE_THREAD_LOCAL -DBOOST_COMPUTE_THREAD_SAFE \
        -DBOOST_COMPUTE_DEBUG_KERNEL_COMPILATION $CFLAGS"

# triSYCL kernel specific compilation flags
CFLAGS_KERNEL="-fno-vectorize -fno-unroll-loops"

LDLIBS="-lpthread -lboost_log -lOpenCL $LDLIBS"

# Optional include specifier, they can be speciifed using -I from the command
# line when compiling using the shell anyway, but these help to indicate
# what may be missing...
if ((OPENCL_INCPATH)); then
   CFLAGS="-I$OPENCL_INCPATH $CFLAGS"
fi

if ((BOOST_COMPUTE_INCPATH)); then
   CFLAGS="-I$BOOST_COMPUTE_INCPATH $CFLAGS"
fi

if ((OPENCL_LIBPATH)); then
  LDFLAGS="-L$OPENCL_LIBPATH $LDFLAGS"
fi

# if ((COMPILE_ONLY && OFILE_NAMED)) && [ $# -gt 1 ] ; then
#   usage 3 "cannot specify -o with -c, with multiple files"
# fi

# Note: To keep intermediate files for debugging purposes it may be worthwhile
# to give a user the option to specify a directory to place intermediate files
# instead of invoking mktemp directory
TMP=`mktemp -d`

for FILEPATH in $FILEPATHS
do
  EXT=${FILEPATH##*.}    # Skip object/lib files; though do collect their names
  if [[ $EXT != @(h|c|i|ii|cc|cp|cxx|cpp|c++|C|hh|hp|hxx|hpp|h++|H) ]]; then
    # echo filepath in ext $FILEPATH
    DIRECT=`dirname $FILEPATH`
    # echo directory? $DIRECT
    # ls $DIRECT
    OBJFILES="$FILEPATH $OBJFILES"   # Reverse this to match gcc/clang?
    continue
  fi

  # Complex compilation process, triSYCL projects readme discusses it in detail.
  # Largelly taken from the triSYCL tests/Makefile but condensed to only OpenCL
  # related compilation steps.

  if ((PREPROCESS_ONLY)); then      # Handle -E
    if ((OFILE_NAMED)); then
      # Kernel caller/host
      $CL_CXX -E $OPTS $CFLAGS $INCS $MACROS -sycl -o \
        $OFILE.pre_kernel_caller                            $FILEPATH

      # Kernel/device
      $CL_CXX -E $OPTS $CFLAGS $INCS $MACROS -DTRISYCL_DEVICE -sycl \
        -sycl-is-device $CFLAGS_KERNEL -o $OFILE.pre_kernel $FILEPATH
    else
      # Kernel caller/host
      $CL_CXX -E $OPTS $CFLAGS $INCS $MACROS -sycl          $FILEPATH
      # Kernel/device
      $CL_CXX -E $OPTS $CFLAGS $INCS $MACROS -DTRISYCL_DEVICE -sycl \
       -sycl-is-device $CFLAGS_KERNEL                       $FILEPATH
    fi
    continue
  fi

  FILENAME=_`echo $FILEPATH | tr '//' '#'`  # prepend _ and replace /s with #s
  # OBJFILES="$TMP/$FILENAME.kernel_caller.bc $TMP/$FILENAME.kernel.internalized.cxx $OBJFILES"
  OBJFILES="$TMP/$FILENAME.o $OBJFILES"

  # The LLVM assembly code for the code expected to call the kernels
  $CL_CXX $CFLAGS $INCS $OPTS $MACROS $DEBUG -sycl -emit-llvm -S \
    -o $TMP/$FILENAME.pre_kernel_caller.ll $FILEPATH

  # The LLVM assembly code for the code before kernels
  $CL_CXX $CFLAGS $INCS $OPTS $MACROS $DEBUG -DTRISYCL_DEVICE -sycl \
  -sycl-is-device $CFLAGS_KERNEL -emit-llvm -S -o $TMP/$FILENAME.pre_kernel.ll \
  $FILEPATH

  # Process bitcode with SYCL passes to generate kernels
  $CL_OPT -load $DEVICE_COMPILER_DIR/lib/SYCL.so -globalopt -deadargelim \
      -SYCL-args-flattening -deadargelim -SYCL-kernel-filter -globaldce \
      -RELGCD -inSPIRation -globaldce -o $TMP/$FILENAME.kernel.bin \
      $TMP/$FILENAME.pre_kernel.ll

  # Internalize the kernel binary into cl::sycl::drt::code::program with
  # a C++ file
  # You have to compile triSYCL tool inside hte triSYCL directory for this stage
  $TRISYCL_DIR/src/triSYCL_tool --source-in $TMP/$FILENAME.kernel.bin --output \
      $TMP/$FILENAME.kernel.internalized.cxx

  # Process bitcode with SYCL passes to generate kernel callers
  $CL_OPT -load $DEVICE_COMPILER_DIR/lib/SYCL.so -globalopt -deadargelim \
    -SYCL-args-flattening -loop-idiom -deadargelim -SYCL-serialize-arguments \
    -deadargelim -o $TMP/$FILENAME.kernel_caller.bc \
    $TMP/$FILENAME.pre_kernel_caller.ll

  # Can't truly just Compile Only as we need to link the kernel and kernel
  # caller. In theory can use -flto to link into an object file but requires
  # llvm-gold,so in the compiler path
  $HOST_CXX -o $TMP/$FILENAME.o $OPTS $CFLAGS $LIBPATHS  \
    $TMP/$FILENAME.kernel_caller.bc $TMP/$FILENAME.kernel.internalized.cxx \
    $LDFLAGS $LDLIBS

  if ((COMPILE_ONLY)); then            # Handle -c
    if ((OFILE_NAMED)); then
      cp $TMP/$FILENAME.o $OFILE
      cp $TMP/$FILENAME.kernel_caller.bc $OFILE.kernel_caller.bc
      cp $TMP/$FILENAME.kernel.internalized.cxx $OFILE.kernel.internalized.cxx
    else
      cp $TMP/$FILENAME.o \
        $(basename "$FILEPATH" | cut -d. -f1).o
      cp $TMP/$FILENAME.kernel_caller.bc \
        $(basename "$FILEPATH" | cut -d. -f1).kernel_caller.bc
      cp $TMP/$FILENAME.kernel.internalized.cxx \
        $(basename "$FILEPATH" | cut -d. -f1).kernel.internalized.cxx
    fi
  fi
done

if ((!COMPILE_ONLY && !PREPROCESS_ONLY)); then
  # Link the C++-generated kernel caller to the final program
  # $OFILE.kernel_caller i.e. the final output is technically what is emitted
  # here However, I wish to avoid that and keep it as just a standard a.out or
  # OFILE name end product for this script.
  # $HOST_CXX $OBJFILES -o $OFILE $OPTS $CFLAGS $LIBPATHS \
  #   $LDFLAGS $LDLIBS

  # We unfortunately double compile this way right now.., but is there a way to avoid this if
  # I have to fake the -c flag above? can I just output a C++ variaton of the kernel caller for the -C phase?

  # 1) This actually isn't correct as I'd want to create a new list of kernel_caller.bc/kernel.internalized.cxx for all OBJFILE in OBJFILES
  # 2) Perhaps it is possible to do something like a try catch, if i can compile using the OBJFILE without it exploding use that else use the kernel_caller.bc/kernel.internalized.cxx
  # 3) The general concept for this phase is to link all the OBJFILES together which are generated above

  # If all else fails perhaps all this script does is invoke the makefile appropriately..
  for OBJFILE in $OBJFILES
  do
    $HOST_CXX $OBJFILE.kernel_caller.bc $OBJFILE.kernel.internalized.cxx -o $OFILE $OPTS $CFLAGS $LIBPATHS \
    $LDFLAGS $LDLIBS
  done
fi
