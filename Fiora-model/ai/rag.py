import numpy as np
import os
import csv

try:
    import faiss
except Exception as e:
    faiss = None
    print(f"Warning: FAISS unavailable, semantic RAG disabled: {e}")

try:
    from sentence_transformers import SentenceTransformer
except Exception as e:
    SentenceTransformer = None
    print(f"Warning: sentence-transformers unavailable, semantic RAG disabled: {e}")

_model = SentenceTransformer("all-MiniLM-L6-v2") if SentenceTransformer is not None else None
_index = None
_chunks = []

def _build_endometriosis_chunks(csv_path: str) -> list:
    """Convert structured CSV rows into retrieval-friendly natural language chunks."""
    chunks = []
    rows = []

    try:
        with open(csv_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows.append(row)
    except Exception as e:
        print(f"Warning: Could not read endometriosis CSV: {e}")
        return chunks

    if not rows:
        return chunks

    # Add compact aggregate insights first, so retrieval can return high-value context quickly.
    diagnosis_vals = [int(float(r.get("Diagnosis", 0) or 0)) for r in rows]
    pain_vals = [float(r.get("Chronic_Pain_Level", 0) or 0) for r in rows]
    irregular_vals = [int(float(r.get("Menstrual_Irregularity", 0) or 0)) for r in rows]
    infert_vals = [int(float(r.get("Infertility", 0) or 0)) for r in rows]
    hormone_vals = [int(float(r.get("Hormone_Level_Abnormality", 0) or 0)) for r in rows]

    total = len(rows)
    positives = sum(diagnosis_vals)
    prevalence = (positives / total) * 100 if total else 0
    avg_pain = (sum(pain_vals) / len(pain_vals)) if pain_vals else 0
    irregular_rate = (sum(irregular_vals) / len(irregular_vals)) * 100 if irregular_vals else 0
    infert_rate = (sum(infert_vals) / len(infert_vals)) * 100 if infert_vals else 0
    hormone_rate = (sum(hormone_vals) / len(hormone_vals)) * 100 if hormone_vals else 0

    chunks.append(
        "Structured endometriosis dataset summary: "
        f"{total} records, diagnosis-positive prevalence {prevalence:.1f} percent, "
        f"average chronic pain level {avg_pain:.2f}, menstrual irregularity present in {irregular_rate:.1f} percent, "
        f"infertility indicator present in {infert_rate:.1f} percent, hormone abnormality present in {hormone_rate:.1f} percent."
    )

    # Add a subset of row-level narratives to avoid overwhelming memory while preserving examples.
    max_row_chunks = 250
    for i, row in enumerate(rows[:max_row_chunks], start=1):
        chunks.append(
            "Endometriosis data sample "
            f"{i}: age {row.get('Age', 'unknown')}, menstrual irregularity {row.get('Menstrual_Irregularity', 'unknown')}, "
            f"chronic pain level {row.get('Chronic_Pain_Level', 'unknown')}, "
            f"hormone abnormality {row.get('Hormone_Level_Abnormality', 'unknown')}, "
            f"infertility indicator {row.get('Infertility', 'unknown')}, BMI {row.get('BMI', 'unknown')}, "
            f"diagnosis label {row.get('Diagnosis', 'unknown')}."
        )

    return chunks

def _build_cycle_chunks(csv_path: str) -> list:
    """Convert structured cycle CSV rows into retrieval-friendly natural language chunks."""
    chunks = []
    rows = []

    try:
        with open(csv_path, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                rows.append(row)
    except Exception as e:
        print(f"Warning: Could not read cycle CSV: {e}")
        return chunks

    if not rows:
        return chunks

    total = len(rows)
    valid_lengths = [float(r.get("LengthofCycle", 0) or 0) for r in rows if r.get("LengthofCycle")]
    avg_length = (sum(valid_lengths) / len(valid_lengths)) if valid_lengths else 0

    chunks.append(
        "Structured menstrual cycle dataset summary: "
        f"{total} total records tracked. The average cycle length across this dataset is {avg_length:.1f} days. "
        "These patterns help establish baseline metrics for typical menstrual health."
    )

    max_row_chunks = 250
    for i, row in enumerate(rows[:max_row_chunks], start=1):
        chunks.append(
            f"Cycle data sample {i}: Client ID {row.get('ClientID', 'unknown')}, "
            f"Cycle number {row.get('CycleNumber', 'unknown')}, "
            f"Length of cycle {row.get('LengthofCycle', 'unknown')} days."
        )

    return chunks

def _load_kb():
    global _index, _chunks
    kb_path = os.path.join(os.path.dirname(__file__), "../data/health_kb.txt")
    endometriosis_csv_path = os.path.join(os.path.dirname(__file__), "../structured_endometriosis_data.csv")
    cycle_csv_path = os.path.join(os.path.dirname(__file__), "../FedCycleData071012 (2).csv")
    if not os.path.exists(kb_path):
        # Create a starter knowledge base if none exists
        with open(kb_path, "w") as f:
            f.write(
                "Menstrual cycle has four phases: menstrual, follicular, ovulatory, luteal.\n"
                "During the menstrual phase, gentle yoga and rest are recommended.\n"
                "Iron-rich foods like spinach and lentils help during menstruation.\n"
                "PCOS symptoms include irregular periods, acne, and weight changes.\n"
                "Endometriosis causes severe pain during periods and requires medical diagnosis.\n"
                "During the follicular phase, energy increases and cardio exercise is beneficial.\n"
                "Ovulation typically occurs around day 14 of a 28-day cycle.\n"
                "The luteal phase may bring PMS symptoms including mood changes and bloating.\n"
                "Magnesium can help reduce PMS symptoms and cramps.\n"
                "Tracking your cycle helps identify patterns and predict symptoms.\n"
            )

    with open(kb_path, "r", encoding="utf-8") as f:
        text = f.read()

    kb_chunks = [s.strip() for s in text.split("\n") if len(s.strip()) > 20]
    
    csv_chunks = []
    if os.path.exists(endometriosis_csv_path):
        csv_chunks.extend(_build_endometriosis_chunks(endometriosis_csv_path))
    
    if os.path.exists(cycle_csv_path):
        csv_chunks.extend(_build_cycle_chunks(cycle_csv_path))

    _chunks = kb_chunks + csv_chunks
    
    if len(_chunks) == 0:
        print("Warning: Knowledge base is empty! RAG disabled until data is added.")
        return

    if _model is None or faiss is None:
        # Keep plain chunks loaded; query fallback logic will use lexical matching.
        _index = None
        return

    embeddings = _model.encode(_chunks, convert_to_numpy=True)
    norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    embeddings = embeddings / norms

    _index = faiss.IndexFlatIP(embeddings.shape[1])
    _index.add(embeddings.astype(np.float32))

def query_rag(query: str, top_k: int = 3) -> str:
    global _index, _chunks
    if _index is None:
        _load_kb()

    if _index is None:
        if not _chunks:
            return ""

        # Fallback lexical retrieval when semantic dependencies are unavailable.
        query_terms = {w.strip(".,!?;:\"'()[]{}").lower() for w in query.split() if w.strip()}
        scored = []
        for chunk in _chunks:
            words = {w.strip(".,!?;:\"'()[]{}").lower() for w in chunk.split() if w.strip()}
            overlap = len(query_terms & words)
            scored.append((overlap, chunk))
        scored.sort(key=lambda x: x[0], reverse=True)
        results = [chunk for score, chunk in scored[:top_k] if score > 0]
        if not results:
            results = _chunks[:top_k]
        return "\n".join(results)

    query_vec = _model.encode([query], convert_to_numpy=True)
    query_norm = np.linalg.norm(query_vec)
    if query_norm != 0:
        query_vec = query_vec / query_norm
    _, indices = _index.search(query_vec.astype(np.float32), top_k)

    results = [_chunks[i] for i in indices[0] if i < len(_chunks)]
    return "\n".join(results)

# Load at import time so first request is fast
_load_kb()