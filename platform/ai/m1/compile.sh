#!/bin/bash
# M1 GROMACS Compilation Script (Profiling-Ready)
# This script prepares a binary that is optimized but retains symbols and frame pointers.
set -e

echo "🛠️ Compiling GROMACS for M1 Profiling..."

# 1. Clean previous builds
rm -rf build
mkdir build
cd build

# 2. Configure with profiling-specific flags
# - RelWithDebInfo: Optimized but with debug symbols
# - fno-omit-frame-pointer: Ensures clean call stacks for Instruments/Perf
# - arm64: Explicitly target Apple Silicon
echo "⚙️ Configuring CMake with RelWithDebInfo and Frame Pointers..."
cmake .. \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_C_FLAGS="-fno-omit-frame-pointer" \
    -DCMAKE_CXX_FLAGS="-fno-omit-frame-pointer" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DGMX_GPU=OpenCL \
    -DGMX_BUILD_OWN_FFTW=OFF \
    -DCMAKE_INSTALL_PREFIX=$HOME/gromacs_m1_profile

# 3. Build and Install
echo "🏗️ Building..."
make -j$(sysctl -n hw.ncpu)
make install

echo "✅ Profiling-ready binary installed to $HOME/gromacs_m1_profile"
echo "Source with: source $HOME/gromacs_m1_profile/bin/GMXRC"
