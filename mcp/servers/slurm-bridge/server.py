# Slurm Bridge MCP Server
# This server provides a native interface to the Slurm workload manager,
# allowing Claude to monitor and manage HPC jobs without manual bash parsing.

from mcp.server.fastmcp import FastMCP
import subprocess
import json

# Create an MCP server
mcp = FastMCP("SlurmBridge")

def run_command(cmd):
    """Helper to run shell commands and return output."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stderr}"

@mcp.tool()
def list_jobs(user: str = None):
    """
    List current Slurm jobs.
    Args:
        user: Filter by a specific username. If omitted, lists all visible jobs.
    """
    cmd = ["squeue"]
    if user:
        cmd.extend(["-u", user])

    output = run_command(cmd)
    return f"Current Slurm Jobs:\n{output}"

@mcp.tool()
def get_job_details(job_id: str):
    """
    Get detailed status and configuration for a specific Slurm job.
    Args:
        job_id: The ID of the job to inspect.
    """
    cmd = ["scontrol", "show", "job", job_id]
    output = run_command(cmd)
    return f"Details for Job {job_id}:\n{output}"

@mcp.tool()
def cancel_job(job_id: str):
    """
    Cancel a specific Slurm job.
    Args:
        job_id: The ID of the job to terminate.
    """
    cmd = ["scancel", job_id]
    output = run_command(cmd)
    return f"Attempted to cancel job {job_id}. Result: {output if output else 'Success'}"

if __name__ == "__main__":
    mcp.run()
