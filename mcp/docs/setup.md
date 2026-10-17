# MCP Configuration Guide for GROMACS
# This guide explains how to connect the MCP servers in this repository to your Claude client.

## 1. Server Overview
The `mcp/servers/` directory contains specialized servers that extend Claude's capabilities:
- **Slurm Bridge**: Native interaction with the HPC cluster (`squeue`, `scontrol`, `scancel`).
- **GMX Docs (Planned)**: RAG-based lookup for the GROMACS manual.

## 2. Installation
For each server you wish to enable:
1. Create a virtual environment:
   ```bash
   cd mcp/servers/slurm-bridge
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

## 3. Client Configuration
Add the following to your `claude_desktop_config.json` (or equivalent CLI config):

```json
{
  "mcpServers": {
    "gromacs-slurm": {
      "command": "/Users/grey/work/gromacs/mcp/servers/slurm-bridge/venv/bin/python",
      "args": ["/Users/grey/work/gromacs/mcp/servers/slurm-bridge/server.py"]
    }
  }
}
```

## 4. Testing the Connection
Once configured, you can verify the connection by asking Claude:
- "What is the current status of my Slurm jobs?"
- "Get details for job ID 123456."
