#!/bin/bash
# GROMACS Profiling Build for Apple Silicon (M1/M2/M3)
# This script creates a binary optimized for speed but transparent for profiling.
set -e

echo "======================================================================"
echo "GROMACS Profiling-Ready Build (M1/Apple Silicon)"
echo "======================================================================"

INSTALL_DIR="$HOME/gromacs_m1_profile"
BUILD_DIR="build_profile"

# 1. Dependencies
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew not found. Please install it first: https://brew.sh/"
    exit 1
fi

echo "Ensuring dependencies are installed..."
brew install cmake fftw

# 2. Clean and Setup
echo "Preparing build directory $BUILD_DIR..."
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# 3. Configuration
# RelWithDebInfo: Optimized but retains debug symbols
# -fno-omit-frame-pointer: Essential for accurate Call Stacks/Flame Graphs
echo "Configuring with RelWithDebInfo and Frame Pointers..."
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_C_FLAGS="-fno-omit-frame-pointer" \
    -DCMAKE_CXX_FLAGS="-fno-omit-frame-pointer" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DGMX_GPU=OpenCL \
    -DGMX_BUILD_OWN_FFTW=OFF

# 4. Build and Install
echo "Building GROMACS..."
make -j$(sysctl -n hw.ncpu)
make install

echo "======================================================================"
echo "Profiling-Ready Installation Successful!"
echo "----------------------------------------------------------------------"
echo "To use this binary, source the environment:"
echo "  source $INSTALL_DIR/bin/GMXRC"
echo ""
echo "Verification: Check for symbols using 'nm' or 'dwarfdump'."
echo "======================================================================"
