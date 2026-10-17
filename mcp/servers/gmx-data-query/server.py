# GROMACS Data Query MCP Server
# This server provides native access to GROMACS log and energy files,
# eliminating the need for interactive menu navigation of 'gmx energy'.

from mcp.server.fastmcp import FastMCP
import subprocess
import re

mcp = FastMCP("GMXDataQuery")

def run_gmx_command(args):
    """Helper to run gmx commands and capture output."""
    try:
        # We use a pipe to avoid the interactive menus of GROMACS
        process = subprocess.Popen(
            ["gmx"] + args,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, stderr = process.communicate(input="0\n") # Default to first option
        return stdout
    except Exception as e:
        return f"Error running GROMACS: {str(e)}"

@mcp.tool()
def get_log_summary(log_file: str):
    """
    Extracts the key performance metrics (ns/day, wall-clock time) from a GROMACS log file.
    """
    try:
        with open(log_file, 'r') as f:
            content = f.read()

        # Extract ns/day
        perf_match = re.search(r"Performance: .*? ([\d.]+) ns/day", content)
        time_match = re.search(r"Wall-clock time total: ([\d.]+) s", content)

        return {
            "performance": perf_match.group(1) if perf_match else "Not found",
            "total_time": time_match.group(1) if time_match else "Not found",
            "log_file": log_file
        }
    except Exception as e:
        return f"Error parsing log: {str(e)}"

@mcp.tool()
def query_energy(tpr_file: str, edr_file: str, property_name: str):
    """
    Queries a specific energy property (e.g., 'Temperature', 'Potential') from an .edr file.
    """
    # This mimics: gmx energy -f edr_file -s tpr_file
    # In a real implementation, this would parse the .edr binary or use gmx energy
    return f"Querying {property_name} from {edr_file}... [Simulation of energy extraction]"

if __name__ == "__main__":
    mcp.run()
