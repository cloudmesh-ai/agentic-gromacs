# VMD Bridge MCP Server
# This server interfaces with the VMD (Visual Molecular Dynamics) Tcl console
# to provide remote control of the visualization environment.

from mcp.server.fastmcp import FastMCP
import socket

mcp = FastMCP("VMDBridge")

def send_vmd_command(cmd):
    """Sends a Tcl command to the VMD server via TCP socket."""
    try:
        # VMD typically listens on port 5000 or a configured port
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect(("localhost", 5000))
            s.sendall((cmd + "\n").encode())
            return "Command sent to VMD successfully."
    except Exception as e:
        return f"Failed to connect to VMD: {str(e)}. Ensure VMD is running with a listener."

@mcp.tool()
def vmd_set_representation(selection: str, style: str, color: str):
    """
    Changes the visual representation of a specific molecular selection.
    Example: selection='protein', style='NewCartoon', color='red'
    """
    tcl_cmd = f"mol modstyle 0 {selection} {style} {color}"
    return send_vmd_command(tcl_cmd)

@mcp.tool()
def vmd_center_on(selection: str):
    """Centers the VMD view on the specified molecular selection."""
    tcl_cmd = f"display center {selection}"
    return send_vmd_command(tcl_cmd)

@mcp.tool()
def vmd_export_frame(frame_id: int, filename: str):
    """Captures a high-resolution image of a specific frame."""
    tcl_cmd = f"render snapshot {filename} frame {frame_id}"
    return send_vmd_command(tcl_cmd)

if __name__ == "__main__":
    mcp.run()
