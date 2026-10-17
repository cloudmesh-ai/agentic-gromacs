import os
import pickle
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer
from fastmcp import FastMCP

# Configuration
INDEX_DIR = "index"
INDEX_FILE = os.path.join(INDEX_DIR, "faiss.index")
METADATA_FILE = os.path.join(INDEX_DIR, "metadata.pkl")
MODEL_NAME = "all-MiniLM-L6-v2"

# Initialize FastMCP
mcp = FastMCP("GROMACS Manual RAG")

# Global variables to hold the index and metadata
index = None
metadata = None
model = None

def load_resources():
    global index, metadata, model

    if index is not None:
        return

    print("Loading RAG resources...")
    try:
        # Load model
        model = SentenceTransformer(MODEL_NAME)

        # Load FAISS index
        if not os.path.exists(INDEX_FILE):
            raise FileNotFoundError(f"Index file not found at {INDEX_FILE}. Please run setup_index.py first.")
        index = faiss.read_index(INDEX_FILE)

        # Load metadata
        if not os.path.exists(METADATA_FILE):
            raise FileNotFoundError(f"Metadata file not found at {METADATA_FILE}. Please run setup_index.py first.")
        with open(METADATA_FILE, 'rb') as f:
            metadata = pickle.load(f)

        print("Resources loaded successfully.")
    except Exception as e:
        print(f"Error loading resources: {e}")
        raise e

@mcp.tool()
def query_manual(query: str) -> str:
    """
    Query the GROMACS manual to find relevant information about settings, commands, and theory.

    Args:
        query: The search query related to GROMACS.
    """
    try:
        load_resources()
    except Exception as e:
        return f"Error initializing manual index: {str(e)}. Please ensure setup_index.py has been run."

    # Embed the query
    query_embedding = model.encode([query])

    # Search the index
    # k=5 for top 5 results
    D, I = index.search(np.array(query_embedding).astype('float32'), k=5)

    results = []
    for i in range(len(I[0])):
        idx = I[0][i]
        if idx == -1:
            continue

        chunk = metadata[idx]
        page = chunk["page"]
        text = chunk["text"].strip()
        distance = D[0][i]

        results.append(f"--- Result {i+1} (Page {page}, Distance {distance:.4f}) ---\n{text}\n")

    if not results:
        return "No relevant sections found in the GROMACS manual."

    return "\n".join(results)

if __name__ == "__main__":
    mcp.run()
