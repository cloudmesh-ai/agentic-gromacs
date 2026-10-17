#!/bin/bash
# M1 GROMACS Analysis Guide
# This script provides a checklist for analyzing GROMACS performance on Apple Silicon.
set -e

echo "🔍 GROMACS M1 Analysis Checklist"
echo "================================="
echo ""
echo "1. VISUALIZING THE CALL STACK"
echo "   - Open your .trace file in Xcode Instruments."
echo "   - Switch to the 'Call Tree' view."
echo "   - Check 'Invert Call Tree' and 'Hide System Libraries' for a cleaner view."
echo "   - The functions at the top with the highest % are your bottlenecks."
echo ""
echo "2. M1-SPECIFIC BOTTLENECKS TO LOOK FOR"
echo "   - OpenCL Overhead: Look for high time spent in 'clEnqueueNDRangeKernel'."
echo "   - Memory Bandwidth: If the CPU is waiting on memory, you'll see high 'Idle' time."
echo "   - Thread Contention: Check for locks or synchronization overhead in the Call Tree."
echo ""
echo "3. NEXT STEPS"
echo "   - If a specific C++ function is slow $\rightarrow$ Use /system:analyze-kernels"
echo "   - If you suspect an algorithmic issue $\rightarrow$ Use /benchmark:simulation-profile"
echo "   - If you need to optimize the setup $\rightarrow$ Use /sim:mdp-optimize"
echo ""
echo "================================="
