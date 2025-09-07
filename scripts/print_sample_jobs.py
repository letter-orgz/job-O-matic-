import json
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "data" / "imports" / "sample_jobs.json"
if not p.exists():
    print("No sample jobs found at", p)
    raise SystemExit(1)

jobs = json.loads(p.read_text())
print(f"Loaded {len(jobs)} sample jobs:\n")
for j in jobs:
    print(f"[{j['id']}] {j['title']} @ {j['company']} ({j['location']}) - {j['status']}")
    print("   ", j['description'])
    print()
