#!/bin/bash

[ -z "$TRISYCL" ] && usage 2 "create and initialise a TRISYCL environment var"
[ -z "$TRISYCL_TARGET" ] && usage 2 "create and initialise a TRISYCL_TARGET environment var"

echo TRISYCL is set to $TRISYCL
echo TRISYCL_TARGET is set to $TRISYCL_TARGET
