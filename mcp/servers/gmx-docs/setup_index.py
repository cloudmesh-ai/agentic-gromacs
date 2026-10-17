import os
import requests
from pypdf import PdfReader
from sentence_transformers import SentenceTransformer
import faiss
import numpy as np
import pickle

# Configuration
# Try to use a recent stable version. 2024 is typically stable.
MANUAL_URL = "https://ftp.gromacs.org/pub/manual/manual-2024.pdf"
INDEX_DIR = "index"
INDEX_FILE = os.path.join(INDEX_DIR, "faiss.index")
METADATA_FILE = os.path.join(INDEX_DIR, "metadata.pkl")
MODEL_NAME = "all-MiniLM-L6-v2"

def download_pdf(url, output_path):
    if os.path.exists(output_path):
        print(f"PDF already exists at {output_path}, skipping download.")
        return

    print(f"Downloading manual from {url}...")
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        with open(output_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"Saved to {output_path}")
    except Exception as e:
        print(f"Error downloading PDF: {e}")
        raise

def extract_text_from_pdf(pdf_path):
    print(f"Extracting text from {pdf_path}...")
    reader = PdfReader(pdf_path)
    pages_text = []
    for i, page in enumerate(reader.pages):
        text = page.extract_text()
        if text:
            pages_text.append({"page": i + 1, "text": text})
    return pages_text

def chunk_text(pages_text, chunk_size=1000, overlap=100):
    print("Chunking text...")
    chunks = []
    for page_data in pages_text:
        text = page_data["text"]
        page_num = page_data["page"]

        start = 0
        while start < len(text):
            end = start + chunk_size
            chunk = text[start:end]
            chunks.append({"page": page_num, "text": chunk})
            start += chunk_size - overlap
            if start >= len(text):
                break
    return chunks

def create_index(chunks):
    print(f"Creating index using model {MODEL_NAME}...")
    model = SentenceTransformer(MODEL_NAME)
    texts = [c["text"] for c in chunks]
    embeddings = model.encode(texts, show_progress_bar=True)

    dimension = embeddings.shape[1]
    index = faiss.IndexFlatL2(dimension)
    index.add(np.array(embeddings).astype('float32'))

    return index, chunks

def main():
    if not os.path.exists(INDEX_DIR):
        os.makedirs(INDEX_DIR)

    pdf_path = "gmx_manual.pdf"
    try:
        download_pdf(MANUAL_URL, pdf_path)
    except Exception as e:
        print(f"Critical error downloading PDF: {e}")
        if not os.path.exists(pdf_path):
            print("Manual PDF not found locally. Cannot proceed.")
            return

    pages_text = extract_text_from_pdf(pdf_path)
    if not pages_text:
        print("No text extracted from PDF. Exiting.")
        return

    chunks = chunk_text(pages_text)
    index, metadata = create_index(chunks)

    print(f"Saving index to {INDEX_FILE}...")
    faiss.write_index(index, INDEX_FILE)

    print(f"Saving metadata to {METADATA_FILE}...")
    with open(METADATA_FILE, 'wb') as f:
        pickle.dump(metadata, f)

    print("Index creation complete!")

if __name__ == "__main__":
    main()
