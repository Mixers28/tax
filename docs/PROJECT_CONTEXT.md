# Project Context – Long-Term Memory (LTM)

> High-level design, tech decisions, constraints for this project.  
> This is the **source of truth** for agents and humans.

<!-- SUMMARY_START -->
**Summary (auto-maintained by Agent):**
- Local-first web app for UK Self Assessment 2024-25 using HMRC paper forms as the canonical schema.
- Rails + SQLite + Docker Compose, no external calls, data encrypted at rest.
- Immediate focus: extract box definitions from HMRC forms and build a boxes-first registry + data capture.
<!-- SUMMARY_END -->

---

## 1. Project Overview

- **Name:** tax (UK Self Assessment helper)
- **Owner:** TBD
- **Purpose:** Local-first app that maps user inputs to HMRC SA100/SA102/SA106/SA110 boxes and exports a "copy to HMRC" worksheet.
- **Primary Stack:** Rails 7 + Hotwire, SQLite, Docker Compose.
- **Target Platforms:** Local developer environments (macOS/Linux/WSL).

---

## 2. Core Design Pillars

- Forms-first mapping: every input maps to a specific HMRC box.
- Deterministic calculations only (ANI/HICBC/FTCR), no "AI decides your tax".
- Privacy-first and isolated: local-only, encrypted at rest, no outbound network by default.
- Produce a clear "Copy to HMRC" worksheet for manual filing.

---

## 3. Technical Decisions & Constraints

- Language(s): Ruby (Rails), HTML/CSS/JS (Hotwire).
- Framework(s): Rails 7 + Hotwire.
- Database / storage: SQLite for MVP; encrypted local storage for sensitive data.
- Hosting / deployment: Local Docker Compose from Sprint 1.
- Non-negotiable constraints:
  - No external calls by default; isolation required.
  - Documentation stays in plain Markdown for easy review.

---

## 4. Architecture Snapshot

- Box registry (Form/Page/Box definitions) drives UI and export.
- Box values are stored per return, with evidence links and audit trail.
- Calculators produce deterministic outputs for ANI/HICBC/FTCR.
- Exporter generates "Copy to HMRC" worksheet (PDF + JSON).

---

## 5. Links & Related Docs

- Roadmap: docs/NOW.md
- Design docs: docs/spec.md, docs/AGENT_SESSION_PROTOCOL.md
- References: docs/references/sa-forms-2025-redacted.pdf, docs/references/sa-forms-2025-boxes-first-pass.md
- Product / UX docs: docs/PROJECT_CONTEXT.md, docs/NOW.md

---

## 6. Change Log (High-Level Decisions)

Use this section for **big decisions** only:

- `2026-01-01` – Chose Rails + Hotwire and Docker Compose for MVP; no external calls by default.
