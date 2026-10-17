# GROMACS MCP Integration Layer

This directory implements the Model Context Protocol (MCP), transforming the GROMACS toolset from a collection of standalone scripts and skills into an integrated, intelligent system. 

While .claude/skills provide the Instructions (the "how"), the MCP servers provide the Capabilities (the "what").

---

## Architecture

The project is organized into three distinct layers to ensure stability and portability:

Execution Layer (platform/scripts/) ---> Standalone Bash/Python scripts for the user.
       ^
       |
Instruction Layer (.claude/skills/) ---> Guided workflows for the AI Agent.
       ^
       |
Integration Layer (mcp/) ---> Native Tool APIs (Slurm, Docs, Profiling).

---

## Server Catalog

### 1. Slurm Bridge (mcp/servers/slurm-bridge)
A native interface to the Slurm workload manager. It eliminates the need for the AI to parse raw terminal output from squeue or scontrol.
- Capabilities: 
  - list_jobs: Structured monitoring of current cluster activity.
  - get_job_details: Deep inspection of job configurations and status.
  - cancel_job: Direct management of job lifecycles.

### 2. GMX Docs (mcp/servers/gmx-docs)
A RAG-based (Retrieval-Augmented Generation) server for the GROMACS User and Reference Manuals.
- Goal: Provide certified parameter lookups for .mdp files, eliminating the guessing often associated with complex simulation parameters.

### 3. Profile API (mcp/servers/profile-api)
A server designed to parse perf.data and callgrind.out binaries into structured JSON.
- Goal: Allow the AI to read a profile directly rather than relying on the user to describe a Flame Graph.

---

## Roadmap and Next Steps

The integration layer is designed to evolve. The immediate priority is:

Priority 1: The GROMACS Manual RAG Server (mcp/servers/gmx-docs)
- Objective: Ingest the official GROMACS documentation into a vector database.
- Impact: This will enable the /optimize:bottleneck-analysis and /sim:mdp-optimize skills to reference specific manual pages with 100% accuracy, ensuring that every optimization proposal is grounded in official documentation.

Priority 2: The Profiling API (mcp/servers/profile-api)
- Objective: Build a parser for perf and callgrind output files.
- Impact: Allows the agent to autonomously identify the "Flat Tops" in a profile without requiring the user to manually describe the Flame Graph.

---

## Getting Started

### Setup and Connection
Detailed installation steps for the servers and the client configuration are located in:
mcp/docs/setup.md

### Quick Connection Logic
1. Install: Create a venv and install mcp SDK in the server directory.
2. Configure: Add the server path to your claude_desktop_config.json.
3. Invoke: Ask Claude to check your jobs or query the cluster.

---

## MCP vs. Skills: When to use which?

| Feature | Claude Skills (.claude/skills) | MCP Servers (mcp/servers) |
| :--- | :--- | :--- |
| Nature | Markdown-based instructions | Executable code (Python/TS) |
| Role | The "Workflow" (The Logic) | The "Tool" (The API) |
| Example | /optimize:bottleneck-analysis | get_job_details(id) |
| Execution | Agent follows a step-by-step guide | Agent calls a structured function |
| Output | Textual guidance/Bash commands | Structured JSON data |

The Synergy: A Skill will often call one or more MCP Tools to gather data, then use the Skill's logic to interpret that data and propose an optimization.
