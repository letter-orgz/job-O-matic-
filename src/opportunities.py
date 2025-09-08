from __future__ import annotations
"""Utility functions for storing and retrieving tracked opportunities.

This module centralises file access so the Streamlit UI can remain clean and
focus on presentation. Opportunities are stored in a JSON array where each
entry represents a single application record.
"""

from pathlib import Path
import json
from typing import List, Dict, Any

# Default location for stored opportunities. The parent directory is created
# automatically if it does not yet exist.
DATA_PATH = Path("data/opportunities.json")


def load_opportunities(path: Path = DATA_PATH) -> List[Dict[str, Any]]:
    """Load opportunity records from *path*.

    Parameters
    ----------
    path:
        Optional custom path to the opportunities JSON file.
    """
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return []


def save_opportunities(opportunities: List[Dict[str, Any]], path: Path = DATA_PATH) -> None:
    """Persist *opportunities* to disk as formatted JSON."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(opportunities, indent=2), encoding="utf-8")


def add_opportunity(opportunity: Dict[str, Any], path: Path = DATA_PATH) -> None:
    """Append a single *opportunity* to the stored collection."""
    opportunities = load_opportunities(path)
    opportunities.append(opportunity)
    save_opportunities(opportunities, path)
