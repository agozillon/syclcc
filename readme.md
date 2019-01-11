A collection of bash scripts for use with
[ComputeCpp](https://developer.codeplay.com/computecppce/latest/overview),
Codeplay's implementation of the Khronos SYCL specification. As well as
[triSYCL](https://github.com/triSYCL/) an open source implementation of the Khronos
SYCL specification.

The syclcc project is separated into two sub directories of scripts one for each
SYCL implementation. Each of these sub directories has one main executable bash
script, `trisyclcc` and `computecppcc`. They attempt to provide a drop-in
replacement for GCC or Clang. For example:

`computecppcc hello-sycl.cpp`

...will create the binary executable, `a.out`, in the current directory;
assuming you have added the location of `computecppcc` to your `PATH` environment
variable.

Both of these scripts function slightly differently based on the need of the
SYCL implementation. However, the main intent for both scripts is to help
make SYCL code compilation easier.

`computecppcc` is a simple script which calls the main script aligned with
the version of Codeplay's ComputeCpp which you are working with. The version of
ComputeCpp targeted is determined by the environment variable, `COMPUTECPP_DIR`,
which you should set up. `COMPUTECPP_DIR` should reference the root directory of
your ComputeCpp installation, and so `$COMPUTECPP_DIR/bin/compute++` should invoke
Codeplay's `compute++` compiler.

`trisyclcc` is a simple script which calls the main script aligned with
the target you wish to compile for e.g. OpenMP, OpenCL, Xilinx hardware emulation
or software emulation. Currently only the OpenMP script has been fleshed out. The
goal of these scripts is to make compiling for different targets with triSYCL
much simpler. To specify the compilation target the `TRISYCL_TARGET` environment
variable should be set, e.g. `TRISYCL_TARGET=OpenMP`. Similarly to the
`computecppcc` script the root directory of your triSYCL installation should be
specified by an environment variable, in this case `TRISYCL_DIR`.

The `computecppcc` and `trisyclcc` scripts can be tested with any C++ files.

The `computecppcc` scripts can also be tested with Codeplay's own SYCL
[examples](https://github.com/codeplaysoftware/computecpp-sdk). They can also
be used to build the SYCL module for
[SLAMBench](https://github.com/pamela-project/slambench) found at
https://github.com/agozillon/syclslambench.

Similarly the `trisyclcc` scripts can be tested with triSYCL's own SYCL
[examples](https://github.com/triSYCL/triSYCL/tree/master/tests). They can also
be used to build the SYCL module for
[SLAMBench](https://github.com/pamela-project/slambench) found at
https://github.com/agozillon/syclslambench.

A native host compiler is assumed to be present; and this may be Clang or GCC.
Simply modify the `HOST_CXX` entry at the top of the scripts invoked by
`computecppcc` or `trisyclcc`.

In future the `trisyclcc` scripts will also require a device compiler similar to
ComputeCpp, for the moment as we're only compiling for OpenMP this is not
required.

The `computecppcc` scripts have been tested using the Intel OpenCL drivers on
CPU. To ensure ComputeCpp is configured for this, the `COMPUTECPP_TARGET`
environment variable should be set to `intel:cpu`. This setting can be
the difference between runtime success, and a segmentation fault.

For the moment the `trisyclcc` scripts only have the OpenMP script implemented,
however future updates will aim to target other implementations such as the open
source POCL drivers for OpenCL.

You can also cycle through the version of ComputeCpp targeted by `computecppcc`
using three helper scripts. The scripts should be invoked using the linux `source`
command (shown using the bash dot/period operator below), and assume that all
ComputeCpp releases exist in the same directory (e.g. `$HOME/apps/codeplay`),
with default directory names:

`. computecppcc-curr.sh` # makes no changes, echoes the release in use

`. computecppcc-next.sh` # select the next ComputeCpp release

`. computecppcc-prev.sh` # select the previous ComputeCpp release

`computecppcc` # executes the currently selected ComputeCpp release's computecppcc script

The `computecppcc` scripts work with the following versions of ComputeCpp:

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
* ComputeCpp-CE-1.0.3-Ubuntu-16.04-x86_64

Similarly you can cycle through the targets of triSYCL targeted by `trisyclcc`
using three helper scripts. The scripts should be invoked using the linux `source`
command (shown using the bash dot/period operator below):

`. trisyclcc-curr.sh` # makes no changes, echoes the release in use

`. trisyclcc-next.sh` # select the next triSYCL target script

`. trisyclcc-prev.sh` # select the previous triSYCL target script

`trisyclcc` # executes the currently selected triSYCL targets trisyclcc script

The `trisyclcc` scripts work with the following targets:
  * OpenMP
