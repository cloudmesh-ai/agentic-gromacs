
Here is our current build script for Gromacs:

```
#!/bin/bash

set -x
set -e

# things will be installed to `${gmx_install_dir}/install`
gmx_install_dir=/path/to/install/things

cd $gmx_install_dir

### Load modules ###
module load PrgEnv-amd
module load amd
module load rocm
module load hwloc

### Build and Install Boost ###

# Can't use OLCF-provided Boost module because missing the fiber libraries for ACPP
wget https://archives.boost.io/release/1.86.0/source/boost_1_86_0.tar.gz
tar -xvf boost_1_86_0.tar.gz
cd boost_1_86_0

# Copying over Boost header files manually
# so that ACPP doesn't find old Boost header files in `/usr/local/`.
# Think there's a way around this with the `b2` or `bootstrap` script but couldn't figure it out
mkdir -p $gmx_install_dir/install/boost_1_86_0/include
cp -r boost/ $gmx_install_dir/install/boost_1_86_0/include

# Build the Boost library files (including the `fiber` option)
./bootstrap.sh --prefix=$gmx_install_dir/install/boost_1_86_0 --with-libraries=fiber 
./b2 install

### Build and Install ACPP ###
cd $gmx_install_dir
git clone https://github.com/AdaptiveCpp/AdaptiveCpp.git AdaptiveCpp-24.10.0
cd AdaptiveCpp-24.10.0
git checkout v24.10.0
mkdir build
cd build

cmake .. -DCMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/clang -DCMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/clang++ -DLLVM_DIR=${ROCM_PATH}/llvm/lib/cmake/llvm/ -DROCM_PATH=${ROCM_PATH} -DCMAKE_INSTALL_PREFIX=$gmx_install_dir/install/AdaptiveCpp-24.10.0/ -DBOOST_ROOT=$gmx_install_dir/install/boost_1_86_0 -DWITH_SSCP_COMPILER=OFF -DWITH_OPENCL_BACKEND=OFF -DWITH_LEVEL_ZERO_BACKEND=OFF

make install

### Build and Install Gromacs ###

cd $gmx_install_dir
wget https://ftp.gromacs.org/gromacs/gromacs-2024.5.tar.gz
tar -xvf gromacs-2024.5.tar.gz
cd gromacs-2024.5
mkdir build
cd build

# Point to above installations
export LD_LIBRARY_PATH=$gmx_install_dir/install/boost_1_86_0/lib:$LD_LIBRARY_PATH
export PATH=$gmx_install_dir/install/AdaptiveCpp-24.10.0/bin:$PATH
export LD_LIBRARY_PATH=$gmx_install_dir/install/AdaptiveCpp-24.10.0/lib:$LD_LIBRARY_PATH

cmake .. \
  -DGMX_MPI=ON \
  -DGMX_HWLOC:BOOL=ON \
  -DGMX_GPU=SYCL \
  -DGMX_SYCL=ACPP \
  -DGMX_OPENMP:BOOL=ON \
  -DGMX_BUILD_OWN_FFTW=ON \
  -DGMX_FFT_LIBRARY=fftw3 \
  -DREGRESSIONTEST_DOWNLOAD=ON \
  -DCMAKE_C_COMPILER=${ROCM_PATH}/llvm/bin/clang \
  -DCMAKE_CXX_COMPILER=${ROCM_PATH}/llvm/bin/clang++ \
  -DCMAKE_INSTALL_PREFIX=$gmx_install_dir/install/gromacs-2024.5-fftw3 \
  -DGMX_GPLUSPLUS_PATH=/opt/cray/pe/gcc-native/13/bin/g++ \
  -DCMAKE_PREFIX_PATH=$gmx_install_dir/install/AdaptiveCpp-24.10.0/ \
  -DACPP_TARGETS=hip:gfx90a

make -j8

# Takes a while to both compile and run,
# so you can skip `make check` if not concerned about running the checks.
# MPI srun checks will fail if not done on a compute node.
# Running `ctest` in the build directory confirmed the MPI tests passed
# make check

make install
```

# Logan W. Gillum
# HPC Engineer
# Oak Ridge Leadership Computing Facility
