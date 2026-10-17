# GROMACS Benchmarking Playbook

This document provides a standardized benchmarking suite to measure and compare performance across three distinct hardware environments: Apple Silicon (Mac), a Linux Workstation, and an NVIDIA A100 Enterprise Cluster.

## 🎯 Benchmark Suite Overview

The following systems are selected to provide a clean comparison from small-scale baselines to enterprise-scale simulations.

### 1. Universal Baseline: Lysozyme in Water
*   **System Size**: ~25,000 atoms.
*   **Target Environments**: All Platforms (Mac, Workstation, A100).
*   **Purpose**: Provides a direct "apples-to-apples" comparison. It evaluates how the integrated OpenCL graphics on Apple Silicon stack up against native Linux drivers and enterprise-grade hardware.
*   **Metric**: Primary focus on **ns/day**.

### 2. Intermediate Workstation Benchmark: Alcohol Dehydrogenase (ADH)
*   **System Size**: ~95,000 atoms.
*   **Target Environments**: Linux Workstation.
*   **Purpose**: Designed to stretch the limits of local workstation hardware without overwhelming memory or storage. It tests the efficiency of the CUDA implementation on consumer-grade RTX cards.

### 3. HPC Scalability Benchmark: Satellite Tobacco Mosaic Virus (STMV)
*   **System Size**: 1,000,000+ atoms.
*   **Target Environment**: NVIDIA A100 Cluster (via Slurm).
*   **Purpose**: Evaluates enterprise-scale performance and parallelization efficiency.
*   **Scalability Tests**:
    *   **Single Node**: 1x A100.
    *   **Multi-GPU Scaling**: Parallelized runs from 2 up to 8x A100s.
    *   **Analysis**: Testing the optimal MPI-to-GPU ratios to ensure the interconnect doesn't bottleneck the compute.

---

## 🛠 Execution Blueprints

### Apple Silicon (Mac)
To force the integrated GPU to accept compute commands, the following environment bypass must be used:
```bash
export GMX_GPU_DISABLE_COMPATIBILITY_CHECK=1
gmx mdrun -deffnm benchmark_lysozyme
```

### HPC Cluster (Slurm)
For the STMV benchmarks, use a tailored `sbatch` directive. 

**Example for 8x A100 scaling:**
```bash
#!/bin/bash
#SBATCH --job-name=gmx_stmv_8gpu
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:a100:8
#SBATCH --time=48:00:00

module load cuda
module load gromacs

srun gmx_mpi mdrun -deffnm stmv_prod -nb gpu -pme gpu -bonded gpu
```

---

## 📈 Results Tracking Table

Use this table to record the performance of each environment:

| System | Hardware | GPU Accel | Performance (ns/day) | CPU/GPU Util % |
| :--- | :--- | :--- | :--- | :--- |
| **Lysozyme** | M1 Ultra | OpenCL | | |
| **Lysozyme** | Linux WS | CUDA | | |
| **Lysozyme** | A100 | CUDA | | |
| **ADH** | Linux WS | CUDA | | |
| **STMV (1 GPU)**| A100 | CUDA | | |
| **STMV (8 GPU)**| A100 Cluster| CUDA (MPI) | | |
