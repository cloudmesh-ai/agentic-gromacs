#!/bin/bash
set -e # Exit immediately on error

echo "=== Starting GROMACS Build for Linux (RTX 3090) ==="

# 1. Install System Dependencies (Assumes Ubuntu/Debian base)
echo "Installing prerequisites..."
sudo apt update
sudo apt install -y build-essential cmake libfftw3-dev wget

# 2. Setup Local Installation Directory (Avoids needing sudo later)
INSTALL_DIR="$HOME/software/gromacs-cuda"
mkdir -p "$INSTALL_DIR"

# 3. Fetch and Extract Source
VERSION="2024"
URL="https://ftp.gromacs.org/pub/gromacs/gromacs-${VERSION}.tar.gz"
cd /tmp
wget "$URL" -O gromacs-${VERSION}.tar.gz
tar -xvzf gromacs-${VERSION}.tar.gz
cd gromacs-${VERSION}/

# 4. Configure & Build
mkdir build && cd build
cmake .. -DGMX_GPU=CUDA \
         -DCMAKE_BUILD_TYPE=Release \
         -DGMX_BUILD_OWN_FFTW=ON \
         -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

echo "Compiling on $(nproc) threads..."
make -j$(nproc)
make install

# 5. Connect to active project envrc
# Note: The conditional logic in .envrc handles the sourcing automatically.
echo "Installation complete. Please ensure your .envrc is configured to source $INSTALL_DIR/bin/GMXRC"

echo "=== GROMACS Installation Complete! ==="
