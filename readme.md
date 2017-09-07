A collection of bash scripts for use with
[ComputeCpp](https://developer.codeplay.com/computecppce/latest/overview),
Codeplay's beta SYCL implementation. The main script, `syclcc`, attempts to
provide a drop-in replacement for GCC. For example:

`syclcc hello-sycl.cpp`

...will create the binary executable, `a.out`, in the current directory;
assuming you have added `syclcc` to your `PATH` environment variable. `syclcc`
is a simple script which then calls the main script appropriate for the version
of Codeplay's ComputeCpp which you are working with. The version of ComputeCpp
targeted is determined by the environment variable, `COMPUTECPP`, which you
should set up. `COMPUTECPP` should reference the root directory of your
ComputeCpp installation, and so `$COMPUTECPP/bin/compute++` should invoke
Codeplay's `compute++` compiler.

These scripts can be tested with Codeplay's own SYCL [examples](https://github.com/codeplaysoftware/computecpp-sdk). It's also for use in conjunction with compilation of the SYCL module for [SLAMBench](https://github.com/pamela-project/slambench).

A native host compiler is assumed to be present; and this may be Clang or GCC.
Simply modify the `HOST_CXX` entry at the top of the script invoked by `syclcc`.

You can also cycle through several ComputeCpp release versions. and execute
them to compile source code. The scripts assume that all releases exist in the
same directory - e.g. `$HOME/apps/codeplay`

Command/Script List:

`. syclcc-curr.sh` # makes no changes, echos the release in use. 

`. syclcc-next.sh` # select the next ComputeCpp release

`. syclcc-prev.sh` # select the previous ComputeCpp release

`syclcc` # executes the currently selected SYCL release's syclcc shell script

The scripts work with the following versions of ComputeCpp: ComputeCpp-15.06-Linux; ComputeCpp-15.10-Linux; ComputeCpp-16.03-Linux; ComputeCpp-16.05-Linux; ComputeCpp-CE-0.1-Linux; ComputeCpp-CE-0.3.0-Linux.

