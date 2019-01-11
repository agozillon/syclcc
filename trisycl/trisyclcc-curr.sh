#!/bin/bash

#########################################################################################
#                                                                                       #
# Copyright (c) 2019 Andrew Gozillon and Paul Keir, University of the West of Scotland. #
#                                                                                       #
#########################################################################################

[ -z "$TRISYCL_DIR" ] && usage 2 "create and initialise a TRISYCL_DIR environment var"
[ -z "$TRISYCL_TARGET" ] && usage 2 "create and initialise a TRISYCL_TARGET environment var"

echo TRISYCL_DIR is set to $TRISYCL_DIR
echo TRISYCL_TARGET is set to $TRISYCL_TARGET
