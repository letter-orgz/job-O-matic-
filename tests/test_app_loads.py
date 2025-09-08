"""Basic import test for Streamlit app."""
import os
import sys
from pathlib import Path

def test_app_loads():
    os.environ["STREAMLIT_HEADLESS"] = "1"
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    __import__("app")
