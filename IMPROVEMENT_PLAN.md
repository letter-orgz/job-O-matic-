# Job-O-Matic Improvement Plan

## Sprint 1 – Repository hygiene & structure (1 day)
1. **Flatten the root**  
   • Move `app.py`, `start.sh` → `src/`  
   • Add `src/__init__.py` and update README:  
   ```
   streamlit run src/app.py
   ```
2. **Standardize config**  
   • Rename `config_template.env` → `.env.example`  
   • Add `.streamlit/config.toml`  
   ```
   [server]
   headless = true
   port     = 8501
   enableXsrfProtection = false
   ```
3. **Prune bloat**  
   • Delete or archive `lab report 2/**`, `generated_image*.png`, `requirements_updated.txt`  
   • Move `raw cv files/*` → `data/cv/` and rename to `snake_case.docx`
4. **Pin dependencies** (`requirements.txt`)  
   ```
   streamlit==1.33.0
   pandas==2.1.4
   python-dotenv==1.0.0
   # …
   ```

---

## Sprint 2 – Tooling & quality gates (1 day)
1. **Pre-commit hooks**
   ```
   pip install pre-commit
   pre-commit install
   ```
   `.pre-commit-config.yaml`
   ```
   repos:
     - repo: https://github.com/psf/black
       rev: 23.12.1
       hooks: [id: black]
     - repo: https://github.com/astral-sh/ruff
       rev: v0.4.1
       hooks: [id: ruff]
     - repo: https://github.com/PyCQA/bandit
       rev: 1.7.6
       hooks: [id: bandit]
   ```
2. **Minimal tests** (`tests/test_smoke.py`)
   ```
   import streamlit as st
   def test_app_import():
       import src.app  # noqa
   ```
3. **CI workflow** (`.github/workflows/ci.yml`)
   ```
   on: [push, pull_request]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with: { python-version: '3.11' }
         - run: pip install -r requirements.txt
         - run: pytest -q
   ```

---

## Sprint 3 – Mobile & static build (1 day)
1. **Build with stlite**
   ```
   npm install -g stlite
   stlite build src/app.py        # ➜ dist/
   ```
2. **Deploy to Vercel**  
   Add `vercel.json`
   ```
   { "rewrites": [ { "source": "/(.*)", "destination": "/index.html" } ] }
   ```
   Push `dist/` on branch `mobile-build` and link to Vercel project.
3. **README update** – add “Mobile URL:” placeholder.

---

## Sprint 4 – Performance tracking (½ day)
1. Commit `profile_build.sh` timing script.  
2. Add a GitHub Action that runs the script before/after each PR and comments deltas.

---

## Sprint 5 – Feature backlog (ongoing)

| Priority | Enhancement | Notes |
|----------|-------------|-------|
| ⭐⭐⭐ | Streamlit **Session State** navigation | Keeps filters when jumping between pages |
| ⭐⭐ | **SQLite** via SQLModel | Real persistence for Codespaces & mobile |
| ⭐ | **OAuth** (Google/Microsoft) | Optional shared-deployment login |
| ⭐ | **Analytics dashboard** | Chart interview rate vs. platform |

---

## Automating with Codex
1. Save this file as `IMPROVEMENT_PLAN.md` in the repo.  
2. Tell Codex:  
   ```
   Execute Sprint 1 per IMPROVEMENT_PLAN.md.
   Keep each commit <3 MB and run pytest.
   ```  
3. Approve each PR; Codex will chain into the next sprint.

---

### Expected gains
- Repo size ↓ ≈40 %  
- Cold-start build time ↓ 25-35 s  
- Mobile-ready static bundle on HTTPS  
- CI, lint, and security checks on every commit  
- Clear roadmap for future features

Complete these five sprints and **Job-O-Matic** evolves from proof-of-concept to a robust, mobile-friendly, CI-guarded product—all manageable from your phone.
