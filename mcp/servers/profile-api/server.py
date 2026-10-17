from typing import Dict, List, Any, Optional
import subprocess
import re
import os
from fastmcp import FastMCP

# Create an MCP server
mcp = FastMCP("profile-api")

def is_binary(file_path: str) -> bool:
    """Check if a file is binary."""
    try:
        with open(file_path, 'tr') as f:
            f.read(1024)
            return False
    except UnicodeDecodeError:
        return True

@mcp.tool()
def parse_perf_data(file_path: str) -> Dict[str, Any]:
    """
    Extracts the call graph and time spent in functions from a perf.data or perf script output.

    Args:
        file_path: Path to the perf.data file or a file containing 'perf script' output.

    Returns:
        A structured JSON object containing total samples, function samples, and call graph data.
    """
    if not os.path.exists(file_path):
        return {"error": f"File not found: {file_path}"}

    function_samples: Dict[str, int] = {}
    call_graph: Dict[str, Dict[str, int]] = {}
    total_samples = 0

    # Regex to find the function name.
    # Typical line: "  perf script" output varies, but we look for the last symbol in the chain
    # or just any symbol.
    symbol_regex = re.compile(r'([a-zA-Z_][a-zA-Z0-9_.]*)\s*\(?(\+0x[0-9a-fA-F]+)?\)?')

    if is_binary(file_path):
        try:
            # Stream the output of perf script to avoid loading it all into memory
            process = subprocess.Popen(
                ["perf", "script", "-i", file_path],
                stdout=subprocess.PIPE,
                text=True,
                bufsize=1
            )
            for line in process.stdout:
                if not line.strip():
                    continue
                symbols = symbol_regex.findall(line)
                if not symbols:
                    continue
                total_samples += 1
                leaf_func = symbols[0][0]
                function_samples[leaf_func] = function_samples.get(leaf_func, 0) + 1
                for i in range(len(symbols) - 1):
                    child = symbols[i][0]
                    parent = symbols[i+1][0]
                    if parent not in call_graph:
                        call_graph[parent] = {}
                    call_graph[parent][child] = call_graph[parent].get(child, 0) + 1
            process.wait()
            if process.returncode != 0:
                return {"error": f"perf script exited with error code {process.returncode}"}
        except Exception as e:
            return {"error": f"Failed to run perf script: {str(e)}"}
    else:
        try:
            with open(file_path, 'r') as f:
                for line in f:
                    if not line.strip():
                        continue
                    symbols = symbol_regex.findall(line)
                    if not symbols:
                        continue
                    total_samples += 1
                    leaf_func = symbols[0][0]
                    function_samples[leaf_func] = function_samples.get(leaf_func, 0) + 1
                    for i in range(len(symbols) - 1):
                        child = symbols[i][0]
                        parent = symbols[i+1][0]
                        if parent not in call_graph:
                            call_graph[parent] = {}
                        call_graph[parent][child] = call_graph[parent].get(child, 0) + 1
        except Exception as e:
            return {"error": f"Failed to read file: {str(e)}"}

    # Calculate percentages and format for 'Flat Tops'
    flat_tops = []
    for func, count in function_samples.items():
        flat_tops.append({
            "function": func,
            "samples": count,
            "percentage": (count / total_samples * 100) if total_samples > 0 else 0
        })

    # Sort by samples descending
    flat_tops.sort(key=lambda x: x["samples"], reverse=True)

    return {
        "total_samples": total_samples,
        "top_functions": flat_tops[:50], # Top 50 for LLM consumption
        "call_graph": call_graph
    }

@mcp.tool()
def analyze_callgrind(file_path: str) -> Dict[str, Any]:
    """
    Parses callgrind.out files to return instruction counts and cache misses for the top functions.

    Args:
        file_path: Path to the callgrind.out file.

    Returns:
        A structured JSON object with top functions, their instruction reads (Ir), and other metrics.
    """
    if not os.path.exists(file_path):
        return {"error": f"File not found: {file_path}"}

    try:
        with open(file_path, 'r') as f:
            # We can't use readlines() for huge files, but callgrind files are usually
            # manageable unless very detailed. For safety, we'll iterate.
            functions_data = {}
            current_func = None
            for line in f:
                line = line.strip()
                if line.startswith("fn="):
                    current_func = line[3:]
                    functions_data[current_func] = {}
                elif current_func and line:
                    parts = line.split()
                    if len(parts) >= 2:
                        metric = parts[0]
                        try:
                            value = int(parts[1])
                            functions_data[current_func][metric] = value
                        except ValueError:
                            pass
    except Exception as e:
        return {"error": f"Failed to read file: {str(e)}"}

    # Prepare a list of functions with their primary metric (Ir - Instruction Reads)
    results = []
    for func, metrics in functions_data.items():
        results.append({
            "function": func,
            "instructions": metrics.get("Ir", 0),
            "data_reads": metrics.get("Dr", 0),
            "data_writes": metrics.get("Dw", 0),
            "misses": metrics.get("I1mr", 0) + metrics.get("L1mr", 0)
        })

    # Sort by instructions descending
    results.sort(key=lambda x: x["instructions"], reverse=True)

    return {
        "top_functions": results[:50],
        "summary": {
            "total_functions": len(results)
        }
    }

if __name__ == "__main__":
    mcp.run()
