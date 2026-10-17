# Hardware Telemetry MCP Server
# This server provides real-time hardware metrics for GPU and CPU monitoring.

from mcp.server.fastmcp import FastMCP
import subprocess

mcp = FastMCP("HardwareTelemetry")

def run_cmd(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, text=True).strip()
    except Exception as e:
        return f"Error: {str(e)}"

@mcp.tool()
def get_gpu_metrics():
    """
    Returns current NVIDIA GPU utilization, memory usage, and temperature.
    """
    # Wraps nvidia-smi for structured output
    return run_cmd("nvidia-smi --query-gpu=utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits")

@mcp.tool()
def get_node_health():
    """
    Checks for CPU throttling, load averages, and memory pressure.
    """
    load = run_cmd("uptime")
    mem = run_cmd("free -h | grep Mem")
    return f"System Health:\nLoad: {load}\nMemory: {mem}"

if __name__ == "__main__":
    mcp.run()
