# TODO

## Benchmark Links

https://www.mpinat.mpg.de/grubmueller/bench

https://openbenchmarking.org/test/pts/gromacs

https://manual.gromacs.org/current/onlinehelp/gmx-nonbonded-benchmark.html

https://blog.salad.com/gromacs-benchmark

https://ftp.gromacs.org/pub/benchmarks/

https://hpc.nih.gov/apps/gromacs/

https://docs.bioexcel.eu/gromacs_bpg/en/master/cookbook/cookbook.html

## prof

Since you prefer modern tools, you should skip gprof entirely. Modern Linux performance engineering relies on sampling-based profiling and system tracing. These methods require no code modifications, run with near-zero overhead, and handle multi-threading flawlessly.
Here is the modern Linux stack you should use today:

1. perf + Hotspot (The Modern Gold Standard)

Instead of modifying your code, perf asks the CPU kernel what it is doing thousands of times per second.
• Why it's modern: It profiles your code, shared libraries, and the Linux kernel simultaneously. It handles heavily threaded apps perfectly.
• The Workflow:
    1. Compile your code with debug symbols (-g) so you can see function names, but keep optimizations on (-O2 or -O3).
    2. Record the run: perf record --call-graph dwarf ./your_app
    3. Open the resulting perf.data file in Hotspot (a modern GUI wrapper). It will instantly render a beautiful, interactive Flame Graph where wide bars represent your biggest time-wasters.

2. bpftrace & eBPF (Modern System Tracing)

Extended Berkeley Packet Filter (eBPF) is the most revolutionary technology in modern Linux performance analysis. It lets you run mini-programs directly inside the Linux kernel to safely trace anything.
• Why it's modern: You can write short, one-line scripts to track disk I/O, memory allocations, or network latency across the entire system without slowing your app down.
• Example: bpftrace -e 'tracepoint:syscalls:sys_enter_openat { printf("%s opened %s\\n", comm, str(args->filename)); }' traces every single file opened by your program in real-time.

3. Language-Specific Modern Profilers

If you aren't writing pure C/C++, modern languages have built ecosystem-specific sampling profilers that integrate beautifully with Linux:
• Rust: Uses cargo-instruments or pprof.
• Go: Has pprof built directly into the runtime. You can generate profiles and view them instantly in your web browser as a dynamic graph.
• Python: Uses Py-Spy, a sampling profiler written in Rust that can profile production Python code without restarting the process or slowing it down.

---

## Future Skill Extensions (MCP Integration)

The following areas are targeted for expansion into the MCP (Model Context Protocol) layer to move from "scripts" to "native AI capabilities":

1. **GMX Manual RAG Server**: Ingest official GROMACS documentation to eliminate "guessing" on complex `.mdp` parameters.
2. **GMX-Data-Query Server**: Native parsing of `.log` and `.edr` binary files for instant energy/performance summaries.
3. **Topology-Explorer Server**: Structured API for `.top` and `.itp` files to verify force field parameters and residue properties.
4. **Hardware-Telemetry Server**: Real-time monitoring of GPU/CPU health and utilization (via `nvidia-smi`, `ipmitool`) to detect thermal throttling or memory pressure.
5. **VMD-Bridge Server**: Direct control of the VMD Tcl console to automate visualization, centering, and high-res frame export.

---

## Strategic Evolution (Next Vectors)

To move from "tooling" to a professional performance framework, the following vectors are proposed:

### Vector 1: The "Intelligence" Path (Closing the Knowledge Gap)
- **Project**: Implement the GMX Manual RAG Server.
- **Why**: Ingest official GROMACS manual into a vector database to move from "suggesting" to "referencing" parameters.
- **Outcome**: `/sim:mdp-optimize` and `/optimize:bottleneck-analysis` become 100% evidence-based.

### Vector 2: The "Scientific" Path (Closing the Validation Gap)
- **Project**: Create a Performance Regression Suite.
- **Why**: Use `gmx energy` and `gmx rms` to compare a "Golden Standard" simulation against an "Optimized" one.
- **Outcome**: A `/benchmark:validate` skill that flags numerical drift or unstable energy fluctuations.

### Vector 3: The "Scale" Path (Closing the Data Gap)
- **Project**: Automate the Trajectory Data Pipeline.
- **Why**: Scripted pipeline to auto-reduce trajectories on the cluster, compress, transfer, and trigger `/sim:analyze`.
- **Outcome**: Focus on physics analysis rather than managing `.xtc` files.

| Goal | Vector | Immediate Action |
| :--- | :--- | :--- |
| Absolute Accuracy | Vector 1 (Intelligence) | Build the GMX Manual RAG Server. |
| Scientific Rigor | Vector 2 (Validation) | Create the Regression Testing framework. |
| Workflow Speed | Vector 3 (Scale) | Automate the Data Pipeline. |
