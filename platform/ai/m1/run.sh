#!/bin/bash
# M1 GROMACS Run & Profile Script
# This script runs a short benchmark and provides instructions for capturing a profile.
set -e

# Check if GROMACS is sourced
if [ -z "$GMX_PATH" ]; then
    echo "❌ GROMACS environment not sourced. Please source GMXRC first."
    exit 1
fi

# Use a small dataset for fast profiling (assuming m1-fast is available)
INPUT_FILE="lysozyme.tpr"
if [ ! -f "$INPUT_FILE" ]; then
    echo "⚠️  $INPUT_FILE not found. Please ensure you are in a directory with a .tpr file."
    echo "You can use the m1-fast dataset for quick tests."
    exit 1
fi

echo "🏃 Running short profile run (500 steps)..."
gmx mdrun -s $INPUT_FILE -nsteps 500 -deffnm profile_test

echo "-------------------------------------------------------------------"
echo "📊 PROFILING INSTRUCTIONS FOR M1 MAC"
echo "-------------------------------------------------------------------"
echo "To visualize the performance of this run, use Xcode Instruments:"
echo ""
echo "1. Open 'Instruments' (Cmd + Space -> Instruments)"
echo "2. Select the 'Time Profiler' template."
echo "3. Target: Select 'gmx' from the process list or choose the binary."
echo "4. Click the red 'Record' button."
echo "5. While recording, run the simulation again: gmx mdrun -s $INPUT_FILE -nsteps 500"
echo ""
echo "Once finished, use the 'Call Tree' view to identify the widest bars"
echo "(the most time-consuming functions) just like a Flame Graph."
echo "-------------------------------------------------------------------"
