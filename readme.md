Collection of samples, documentation and utilities for using ComputeCpp,
Codeplay's beta SYCL implementation:

  [link](https://github.com/codeplaysoftware/computecpp-sdk)

git clone https://github.com/codeplaysoftware/computecpp-sdk
. syclcc=next.sh
# or COMPUTECPP=$HOME/apps/codeplay/ComputeCpp-CE-0.3-Linux   # (for example)
cd $COMPUTECPP/computecpp-sdk/samples
mkdir build
cd build
cmake -DCOMPUTECPP_PACKAGE_ROOT_DIR=$COMPUTECPP ..
# or cmake -DCOMPUTECPP_PACKAGE_ROOT_DIR=$PWD/../../.. ..
