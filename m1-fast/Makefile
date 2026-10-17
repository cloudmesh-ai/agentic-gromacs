# GROMACS Fast Test Makefile
# Designed for quick profiling on M1/M2/M3/M4 Macs

GMX := gmx
VERSION := 2024
SOURCE_URL := https://ftp.gromacs.org/pub/gromacs/gromacs-$(VERSION).tar.gz
MDP := dataset/mdp.mdp
GRO := dataset/test.gro
TOP := dataset/topol.top
TPR := test.tpr
LOG := mdrun.log

.PHONY: all download install profile source clean automated-install

all: install profile

# Downloads and builds GROMACS using the project's automated script
automated-install:
	@echo "Launching automated Apple Silicon installation script..."
	bash ../scripts/install_mac_m1max.sh
	@echo "Restart your shell or run 'direnv allow' to apply changes."

# Download the GROMACS source code and extract it.
source:
	@echo, "Downloading GROMACS $(VERSION)..."
	curl -L $(SOURCE_URL) -o gromacs-$(VERSION).tar.gz
	@echo "Extracting source..."
	tar -xzf gromacs-$(VERSION).tar.gz
	@echo "Source downloaded and extracted to gromacs-$(VERSION)/"

# Dataset is pre-provided in the 'dataset/' folder for maximum speed.
# This target verifies the files are present.
download:
	@echo "Checking for fast-test dataset..."
	@test -f $(MDP) && test -f $(GRO) && test -f $(TOP) || (echo "Error: Dataset files missing in dataset/"; exit 1)
	@echo "Dataset verified."

# Verifies that GROMACS is installed and available in the PATH.
install:
	@if ! command -v $(GMX) > /dev/null 2>&1; then \
		echo "-----------------------------------------------------------------"; \
		echo "GROMACS not found in PATH."; \
		echo "You can use the automated script to install:"; \
		echo "  make automated-install"; \
		echo "Or use the project skills:"; \
		echo "  - For quick install: /gromacs-install-quick"; \
		echo "  - For Apple Silicon GPU: /gromacs-install-apple-gpu"; \
		echo "-----------------------------------------------------------------"; \
		exit 1; \
	fi
	@echo "GROMACS installation verified."

# Runs a tiny 100-step simulation to profile performance.
profile: install download
	@echo "Generating TPR file..."
	$(GMX) grompp -f $(MDP) -c $(GRO) -p $(TOP) -o $(TPR) -maxwarn 1
	@echo "Running fast profile (100 steps)..."
	$(GMX) mdrun -s $(TPR) -nsteps 100
	@echo "\n--- Performance Result ---"
	@grep "Performance" $(LOG) || echo "Performance metric not found in log."
	@echo "-------------------------"

clean:
	rm -f $(TPR) $(LOG) *.trr *.edr *.xtc *.log gromacs-$(VERSION).tar.gz
