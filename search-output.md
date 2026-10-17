# GROMACS Performance Benchmark Report

This report synthesizes external performance data for GROMACS to provide a competitive baseline for the user's current hardware suite.

## 📊 Comparative Performance Landscape

The following metrics are estimated based on industry benchmarks for systems of moderate size (e.g., Lysozyme/DH protein).

### Tier 1: Enterprise GPU (NVIDIA A100 80GB)
*   **Performance**: Extremely High.
*   **Expected Range**: 500 - 1,200+ ns/day (depending on MPI scaling and system size).
*   **Notes**: Dominates in large-scale simulations (1M+ atoms). The A100's high memory bandwidth makes it the gold standard for HPC.
*   **Optimization**: Maximum performance requires `-nb gpu -pme gpu -bonded gpu` and optimal MPI task mapping.

### Tier 2: Prosumer GPU (NVIDIA RTX 3090)
*   **Performance**: High.
*   **Expected Range**: 150 - 400 ns/day.
*   **Notes**: Exceptional value for local workstations. While slower than the A100, it significantly outperforms any CPU-only setup.
*   **Optimization**: Best results achieved with CUDA-native builds and all-GPU offloading.

### Tier 3: Apple Silicon (M1/M2 Ultra)
*   **Performance**: Moderate.
*   **Expected Range**: 20 - 80 ns/day (via OpenCL).
*   **Notes**: Performance is heavily dependent on the "Unified Memory" architecture. While significantly slower than a dedicated NVIDIA GPU, it is remarkably efficient for a laptop/compact workstation.
*   **Optimization**: Requires `-DGMX_GPU=OpenCL` and `GMX_GPU_DISABLE_COMPATIBILITY_CHECK=1`.

### Tier 4: CPU-Only (High-Core Count)
*   **Performance**: Low to Moderate.
*   **Expected Range**: 5 - 30 ns/day.
*   **Notes**: Primarily used for setup, energy minimization, or when GPU acceleration is unavailable.

---

## 📈 Summary Comparison Table

| Hardware Tier | Example Hardware | Acceleration | Typical Range (ns/day) | Relative Perf |
| :--- | :--- | :--- | :--- | :--- |
| **Enterprise** | NVIDIA A100 | CUDA | 500 - 1200 | 10x - 20x |
| **Prosumer** | RTX 3090 | CUDA | 150 - 400 | 3x - 8x |
| **Apple Silicon**| M2 Ultra | OpenCL | 20 - 80 | 0.5x - 1.5x |
| **CPU-Only** | Dual Xeon/EPYC | AVX-512 | 5 - 30 | 0.1x - 0.5x |

---

## 🔍 Analysis & Recommendations

Comparing these external baselines to the targets in `benchmarks.md`:

1.  **RTX 3090**: If your results are below 150 ns/day for a Lysozyme-sized system, we should investigate your CUDA build flags or check for thermal throttling.
2.  **M1 Ultra**: If you are seeing < 20 ns/day, it is likely that the GPU is not being utilized and GROMACS has fallen back to CPU-only mode.
3.  **A100 Cluster**: Scaling from 1 to 8 GPUs should show a near-linear increase in ns/day for the STMV system. Any significant plateau suggests an MPI communication bottleneck.
