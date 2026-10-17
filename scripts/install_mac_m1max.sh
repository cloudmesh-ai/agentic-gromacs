#!/bin/bash
set -e

echo "=== Starting GROMACS Build for Mac (M1 Max) ==="

# 1. Install Mac Prerequisites
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is required. Install it from https://brew.sh first."
    exit 1
fi
echo "Installing prerequisites via Homebrew..."
brew install cmake fftw wget libomp

# 2. Setup Local Installation Directory
INSTALL_DIR="$HOME/software/gromacs-opencl"
mkdir -p "$INSTALL_DIR"

# 3. Fetch and Extract Source
VERSION="2024"
URL="https://ftp.gromacs.org/pub/gromacs/gromacs-${VERSION}.tar.gz"
TMP_DIR=$(mktemp -d)
echo "Using temporary directory: $TMP_DIR"
cd "$TMP_DIR"
wget "$URL" -O gromacs-${VERSION}.tar.gz
tar -xvzf gromacs-${VERSION}.tar.gz
cd gromacs-${VERSION}/

# 4. Configure & Build with Apple Silicon Hardware Target
mkdir build && cd build
# We add -DOpenMP_C_FLAGS and -DOpenMP_CXX_FLAGS to point to Homebrew's libomp
# as Apple Clang does not find it automatically.
cmake .. -DGMX_GPU=OpenCL \
         -DCMAKE_BUILD_TYPE=Release \
         -DGMX_BUILD_OWN_FFTW=ON \
         -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
         -DOpenMP_C_FLAGS="-Xpreprocessor -fopenmp" \
         -DOpenMP_CXX_FLAGS="-Xpreprocessor -fopenmp" \
         -DOpenMP_C_LIB_NAMES="omp" \
         -DOpenMP_CXX_LIB_NAMES="omp" \
         -DOpenMP_omp_LIBRARY=$(brew --prefix libomp)/lib/libomp.dylib

CPU_CORES=$(sysctl -n hw.ncpu)
echo "Compiling on $CPU_CORES Mac threads..."
make -j$CPU_CORES
make install

CPU_CORES=$(sysctl -n hw.ncpu)
echo "Compiling on $CPU_CORES Mac threads..."
make -j$CPU_CORES
make install

# 5. Connect to active project envrc
# Note: The conditional logic in .envrc handles the sourcing automatically.
echo "Installation complete. Please ensure your .envrc is configured to source $INSTALL_DIR/bin/GMXRC"

echo "=== GROMACS Installation Complete! ==="
