A collection of bash scripts for use with
[ComputeCpp](https://developer.codeplay.com/computecppce/latest/overview),
Codeplay's beta implementation of the Khronos SYCL specification. The main
executable bash script, `syclcc`, attempts to provide a drop-in replacement for
GCC. For example:

`syclcc hello-sycl.cpp`

...will create the binary executable, `a.out`, in the current directory;
assuming you have added the location of `syclcc` to your `PATH` environment
variable. `syclcc` is a simple script which calls the main script aligned with
the version of Codeplay's ComputeCpp which you are working with. The version of
ComputeCpp targeted is determined by the environment variable, `COMPUTECPP`,
which you should set up. `COMPUTECPP` should reference the root directory of
your ComputeCpp installation, and so `$COMPUTECPP/bin/compute++` should invoke
Codeplay's `compute++` compiler.

These scripts can be tested with any C++ files; as well as Codeplay's own SYCL
[examples](https://github.com/codeplaysoftware/computecpp-sdk). They can also
be used to build the SYCL module for
[SLAMBench](https://github.com/pamela-project/slambench).

A native host compiler is assumed to be present; and this may be Clang or GCC.
Simply modify the `HOST_CXX` entry at the top of the script invoked by `syclcc`.

The `syclcc` script has been tested using the Intel OpenCL drivers on CPU.
To ensure ComputeCpp is configured for this, the `COMPUTECPP_TARGET` environment
variable should be set to `intel:cpu`. This setting can be the difference
between runtime success, and a segmentation fault.

You can also cycle through the version of ComputeCpp targeted by `syclcc` using
three helper scripts. The scripts should be invoked using the linux `source`
command (shown using the bash dot/period operator below), and assume that all
ComputeCpp releases exist in the same directory (e.g. `$HOME/apps/codeplay`),
with default directory names:

`. syclcc-curr.sh` # makes no changes, echoes the release in use

`. syclcc-next.sh` # select the next ComputeCpp release

`. syclcc-prev.sh` # select the previous ComputeCpp release

`syclcc` # executes the currently selected SYCL release's syclcc script

The scripts work with the following versions of ComputeCpp:

* ComputeCpp-15.10-Linux
* ComputeCpp-16.03-Linux
* ComputeCpp-16.05-Linux
* ComputeCpp-CE-0.1-Linux
* ComputeCpp-CE-0.2.0-Linux
* ComputeCpp-CE-0.2.1-Linux
* ComputeCpp-CE-0.3.0-Linux
* ComputeCpp-CE-0.3.1-Linux
* ComputeCpp-CE-0.3.2-Linux
* ComputeCpp-CE-0.3.3-Ubuntu.16.04-64bit
* ComputeCpp-CE-0.4.0-Ubuntu-16.04-64bit
* ComputeCpp-CE-0.5.0-Ubuntu-16.04-64bit
* ComputeCpp-CE-0.5.1-Ubuntu-16.04-64bit
* ComputeCpp-CE-0.6.0-Ubuntu-16.04-64bit
* ComputeCpp-CE-0.6.1-Ubuntu-16.04-64bit
* ComputeCpp-CE-0.7.0-Ubuntu-16.04-x86_64
* ComputeCpp-CE-0.8.0-Ubuntu-16.04-x86_64
* ComputeCpp-CE-0.9.0-Ubuntu-16.04-x86_64
* ComputeCpp-CE-0.9.1-Ubuntu-16.04-x86_64
* ComputeCpp-CE-1.0.0-Ubuntu-16.04-x86_64
* ComputeCpp-CE-1.0.1-Ubuntu-16.04-x86_64
* ComputeCpp-CE-1.0.2-Ubuntu-16.04-x86_64

