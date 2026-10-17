/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install cmake wget gcc libomp fftw hwloc

brew install cmake wget gcc libomp fftw hwloc


wget https://ftp.gromacs.org/gromacs/gromacs-2026.4.tar.gz
wget https://ftp.gromacs.org/regressiontests/regressiontests-2026.4.tar.gz


https://mac.r-project.org/openmp/


tar xfz gromacs-2026.4.tar.gz
tar xfz  regressiontests-2026.4.tar.gz

cd gromacs-2026.4

mkdir build
cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$HOME/gromacs \
  -DGMX_BUILD_OWN_FFTW=ON \
  -DREGRESSIONTEST_DOWNLOAD=OFF \
  -DREGRESSIONTEST_PATH=../../regressiontests-2026.4 \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=gcc \
  -DGMX_OPENMP=OFF



make -j$(sysctl -n hw.logicalcpu)
make check
make install

source $HOME/gromacs/bin/GMXRC
