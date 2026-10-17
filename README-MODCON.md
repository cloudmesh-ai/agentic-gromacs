# ModCon Integration Guide

This directory contains a set of bridge skills that integrate the capabilities of the AI-ModCon organization into the GROMACS performance framework. 

The goal is to leverage general-purpose AI-readiness and benchmarking patterns from ModCon and apply them to the specific challenges of molecular dynamics optimization.

## Integration Logic

ModCon provides high-level frameworks for agent-driven science and data preparation. We map these to GROMACS tasks as follows:

### 1. Performance Tuning (via BaseSIM_APEIRON)
Utilizing the self-improving agent harness to automate the search for optimal GROMACS parameters.
- **Skill**: `/modcon:auto-tune`
- **Action**: Use the APEIRON logic to iteratively adjust `.mdp` parameters and measure ns/day, automatically converging on the best configuration.

### 2. Data Pipeline Optimization (via dsagt)
Using the data-preparation agent to optimize how trajectories and topologies are handled.
- **Skill**: `/modcon:data-prep`
- **Action**: Automate the reduction and cleaning of GROMACS trajectories to prepare them for high-speed analysis.

### 3. Stability Benchmarking (via BaseEval)
Adapting the distribution perturbation methods to test the numerical stability of optimized simulations.
- **Skill**: `/modcon:stability-check`
- **Action**: Perturb input parameters to verify that the performance optimizations have not introduced non-physical artifacts.

---

## How to use ModCon skills
The `/modcon` skills act as high-level orchestrators that call both the native GROMACS skills and the ModCon toolset.

Example:
"Use /modcon:auto-tune to find the best PME settings for this system."
-> The agent will use `mcp/slurm-bridge` to run tests and `mcp/gmx-docs` to verify the suggested parameters.
