# Project Report: GROMACS Performance Engineering & Skill Suite Expansion

## Executive Summary
This activity focused on transforming the GROMACS project from a basic installation and execution suite into a professional-grade performance engineering environment. The primary goal was to eliminate reliance on legacy profiling tools (e.g., `gprof`) and replace them with a modern, high-resolution "Sampling and Tracing" stack. 

The result is a comprehensive ecosystem that enables users to move from a raw simulation crash or slow performance metric to a specific, code-level optimization proposal through a structured "Insight Pipeline."

---

## 1. Simulation Lifecycle & Operational Expansion
The first phase involved filling critical gaps in the simulation workflow to ensure scientific validity and operational stability.

### New Capabilities implemented:
- **MDP Parameter Optimization (`/sim:mdp-optimize`)**: A guide for selecting physically accurate and numerically stable parameters (cut-offs, time-steps) for EM, NVT, NPT, and Production stages.
- **Crash Diagnostics (`/ops:debug-crash`)**: A diagnostic framework to translate cryptic GROMACS error messages (e.g., "LINCS warning", "Water molecule too far") into actionable fixes.
- **Trajectory Post-Processing (`/sim:post-process`)**: Standardized workflows for PBC correction, centering, and fitting, ensuring that analysis is performed on a cleaned trajectory.
- **Version Migration (`/ops:migrate-version`)**: A structured approach to updating scripts and `.mdp` files when migrating between GROMACS versions.
- **Visualization Best Practices**: Updated `/ops:viz-setup` to include publication-quality rendering and VMD automation.

---

## 2. The Modern Performance Stack
The core of the activity was the implementation of a "Modern Gold Standard" for performance analysis. This replaces instrumentation-based profiling with sampling and system tracing.

### The Profiling Pipeline:
The suite now supports a complete high-resolution pipeline:
**Prepare (Build)** $\rightarrow$ **Capture (Sample)** $\rightarrow$ **Transform (Script)** $\rightarrow$ **Visualize (Flame Graph)**

### New Specialized Skills:
- **`install/perf-stack`**: Intelligent discovery and installation of `perf`, `bpftrace`, and `py-spy`, prioritizing existing system modules.
- **`benchmark/compile-profile`**: A critical build skill that enforces `RelWithDebInfo` and `-fno-omit-frame-pointer` to ensure clean call stacks and symbols.
- **`benchmark/profile-modern`**: Implements the `perf` $\rightarrow$ `perf script` $\rightarrow$ **Hotspot/Firefox Profiler** workflow.
- **`benchmark/simulation-profile`**: Deep-dive deterministic analysis using **Valgrind/Callgrind** for instruction-level counting.
- **`benchmark/lang-profile`**: Support for sampling Python wrappers via **Py-Spy** without restarting processes.
- **`system/tracing`**: Real-time system visibility using **eBPF** and **bpftrace** for syscall and I/O latency analysis.

---

## 3. The "Insight Pipeline" (`/optimize:bottleneck-analysis`)
To ensure the profiling data leads to actual speedups, a new "Brain" skill was created. Instead of just identifying "where" time is spent, it analyzes "why" and proposes "how" to fix it.

**The Logic Flow:**
1. **Identify**: Find "Flat Tops" in a Flame Graph.
2. **Diagnose**: Select the correct tool (e.g., `analyze-kernels` for compute, `tracing` for system).
3. **Propose**: Suggest a specific code change or `mdrun` flag.
4. **Verify**: Compare the new profile against the baseline to prove the ns/day increase.

---

## 4. Apple Silicon (M1/M2/M3) Specialization
Recognizing the unique needs of macOS users, a dedicated set of standalone, non-skill-dependent scripts was developed in `platform/scripts/m1/`.

### Standalone Deliverables:
- **`install_gromacs.sh`**: Full OpenCL GPU installation for M1.
- **`compile_profile.sh`**: Generates the profiling-ready binary with frame pointers.
- **`run.sh`**: Orchestrates a benchmark and provides the "Bridge" to Xcode Instruments.
- **`analyze_performance.py`**: A Python tool that parses GROMACS logs and generates a **visual HTML report** of bottlenecks.

---

## Summary of Deliverables

| Category | New/Improved Skills | Standalone Scripts |
| :--- | :--- | :--- |
| **Simulation** | `mdp-optimize`, `post-process` | - |
| **Operations** | `debug-crash`, `migrate-version`, `viz-setup` | - |
| **Profiling** | `compile-profile`, `profile-modern`, `simulation-profile`, `lang-profile` | `compile_profile.sh`, `run.sh` |
| **Tracing** | `system/tracing` | - |
| **Analysis** | `bottleneck-analysis` | `analyze_performance.py` |
| **Installation**| `perf-stack` | `install_gromacs.sh` |

## Conclusion
The project has been evolved from a set of installation guides into a professional performance engineering framework. The user can now move seamlessly from a high-level performance goal to a low-level kernel optimization, supported by an automated, validated, and documented toolchain.
