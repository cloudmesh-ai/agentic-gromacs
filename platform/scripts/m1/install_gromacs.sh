#!/bin/bash
# GROMACS Installation for Apple Silicon (M1/M2/M3)
# This script performs a complete installation of GROMACS with GPU acceleration via OpenCL.
set -e

echo "======================================================================"
echo "GROMACS Apple Silicon Installation Script"
echo "======================================================================"

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew not found. Please install Homebrew first: https://brew.sh/"
    exit 1
fi

# 1. Install Dependencies
echo "Installing system dependencies..."
brew install cmake fftw

# 2. Setup Directories
INSTALL_DIR="$HOME/gromacs_m1"
BUILD_DIR="build_m1"

echo "Setting up build directory at $BUILD_DIR..."
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# 3. Configuration
echo "Configuring for Apple GPU (OpenCL)..."
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    -DGMX_GPU=OpenCL \
    -DGMX_BUILD_OWN_FFTW=OFF \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++

# 4. Build
echo "Building (using all available cores)..."
make -j$(sysctl -n hw.ncpu)

# 5. Install
echo "Installing to $INSTALL_DIR..."
make install

echo "======================================================================"
echo "Installation Successful!"
echo "----------------------------------------------------------------------"
echo "To start using GROMACS, source the environment:"
echo "  source $INSTALL_DIR/bin/GMXRC"
echo ""
echo "Verification command:"
echo "  gmx --version"
echo "======================================================================"
