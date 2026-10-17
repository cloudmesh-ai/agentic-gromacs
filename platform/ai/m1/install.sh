#!/bin/bash
# M1 GROMACS Installation Script
set -e

echo "🚀 Starting GROMACS Installation for Apple Silicon..."

# 1. Install Dependencies
echo "📦 Installing dependencies via Homebrew..."
brew install cmake fftw

# 2. Create build directory
mkdir -p build
cd build

# 3. Configure for Apple GPU (OpenCL)
echo "⚙️ Configuring for Apple GPU..."
cmake .. \
    -DGMX_BUILD_OWN_FFTW=OFF \
    -DGMX_GPU=OpenCL \
    -DCMAKE_INSTALL_PREFIX=$HOME/gromacs_m1

# 4. Build and Install
echo "🛠️ Building GROMACS (this may take a while)..."
make -j$(sysctl -n hw.ncpu)
make install

echo "✅ Installation complete! Source the environment with:"
echo "source $HOME/gromacs_m1/bin/GMXRC"
