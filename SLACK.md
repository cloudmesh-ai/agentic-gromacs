# Slack Communication Summary: #genesis-deepvela-18g

This document summarizes the key discussions, participants, and deliverables from the genesis-deepvela-18g Slack channel.

## Project Context
The channel serves as a coordination hub for a collaborative effort involving multiple researchers and institutions (including ANL, HAL@UW, and others) focused on benchmarking and profiling high-performance workloads on advanced hardware (including the DeepVela-18G platform).

## Key Participants
- **nhanvtran**: Primary coordinator and lead.
- **mattsinc**: Coordination on GitHub organizations and Google Drive permissions.
- **Ben Hawks**: Lead on meeting coordination and benchmarking strategy.
- **Sai Rajat**: Lead on developing Benchmark Runner skills (specifically for AMD MI300X GPUs).
- **Md Khairul Islam**: Focus on MLPerf reproduction and environment setup.
- **Other Members**: Rutwik, monilm, Keita Teranishi, and others.

## Major Discussion Points

### 1. Infrastructure and Access
- **GitHub**: Discussions regarding the creation of a GitHub organization for the project. References were made to `github.com/AI-ModCon` and `github.com/nhanvtran/bench-18g`.
- **Cloud/Cluster Access**: Discussions on running benchmarks on Aurora (ALCF) and NERSC, including the need for account setup and harness coordination.
- **Collaborative Tools**: Use of Google Drive for sharing slides and preparatory materials.

### 2. Benchmarking and Profiling
- **Workloads**: Interest in running benchmarks for `wa-hls4ml`, `LAMMPS`, `Osprey`, and `QMCPack`.
- **Benchmark Runner**: Sai Rajat developed a skill for running workloads on AMD MI300X GPUs, which is intended to be extensible to other GPU architectures.
- **Profiling Focus**: Discussion on profiling `HLS4ML`, specifically looking for representative configuration knobs and parameters.

### 3. Deliverables and Frameworks
- **Benchmark Builder**: An effort to create a demo for a "Benchmark Builder" utilizing AmSC tokens.
- **MLPerf Reproduction**: Discussion on a skill that prepares everything for execution (data download, model setup, environment config) to verify end-to-end runs before profiling.
- **Workflow Mapping**: Identification of a need for a "benchmark profiler" skill to bridge the gap between running a benchmark and analyzing its performance.

## Action Items and References
- **Repos mentioned**:
  - PtychoPINN: `https://github.com/AdvancedPhotonSource/PtychoPINN-torch-pub`
  - Pty-Chi: `https://github.com/AdvancedPhotonSource/pty-chi`
- **Upcoming Milestones**: Coordination of a "ModCon leaderboard" meeting.
