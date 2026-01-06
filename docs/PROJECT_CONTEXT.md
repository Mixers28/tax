# Project Context – Long-Term Memory (LTM)

> High-level design, tech decisions, constraints for this project.  
> This is the **source of truth** for agents and humans.

<!-- SUMMARY_START -->
**Summary (auto-maintained by Agent):**
- Local-first web app for UK Self Assessment 2024-25 using HMRC paper forms as the canonical schema.
- Rails + SQLite + Docker Compose, no external calls, data encrypted at rest.
- Phase 4 complete: PDF/JSON export generation with UTF-8 character encoding.
- Phase 5 spec complete: Full tax calculation engine design (5 sub-phases).
- Phase 5a complete: Basic employment income tax calculator fully operational (database + models + services + UI + export integration).
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
- Local LLM runtime: Ollama (gemma3:1b) via localhost for offline extraction.
- Non-negotiable constraints:
  - No external calls by default; isolation required.
  - Documentation stays in plain Markdown for easy review.

---

## 4. Architecture Snapshot

- Box registry (Form/Page/Box definitions) drives UI and export.
- Box values are stored per return, with evidence links and audit trail.
- Deterministic calculators: ANI/HICBC/FTCR (Phase 4) + Employment Tax Engine (Phase 5a).
- Tax engine: IncomeAggregator → PersonalAllowanceCalculator → TaxBandCalculator → NationalInsuranceCalculator → TaxLiabilityOrchestrator.
- Exporter generates "Copy to HMRC" worksheet (PDF + JSON) with optional tax calculation summaries.

---

## 5. Links & Related Docs

- Roadmap: docs/NOW.md
- Design docs: docs/spec.md, docs/PHASE_5_SPEC.md, docs/AGENT_SESSION_PROTOCOL.md
- Implementation docs: web/PHASE_5A_README.md (architecture, usage, test scenarios)
- References: docs/references/sa-forms-2025-redacted.pdf, docs/references/sa-forms-2025-boxes-first-pass.md
- Forms: docs/references/Blank Tax Return (2025) - SA100-2025.pdf, docs/references/Blank Employment (2025) - SA102_2025.pdf
- Analysis: docs/SPEC_DRIFT_ANALYSIS.md
- Product / UX docs: docs/PROJECT_CONTEXT.md, docs/NOW.md

---

## 6. Change Log (High-Level Decisions)

Use this section for **big decisions** only:

- `2026-01-06` – **Currency support completed:** Implemented Option B (cached exchange rates). EUR/USD income now converts to GBP at form submission. ExchangeRateConfig reads rates from docker-compose.yml environment variables (EUR_TO_GBP_RATE: 0.8650, USD_TO_GBP_RATE: 1.2850). Exchange rate stored in database for audit trail. All amounts normalized to GBP for calculation consistency. Zero external API calls - maintains local-first design. Users can override rates on form if needed.
- `2026-01-06` – **UTF-8 charset fix:** Added `<meta charset="UTF-8">` to application layout. Fixed rendering of £ symbol which was displaying as ? in export calculations and forms.
- `2026-01-06` – Phase 5a fully complete: Income entry UI + calculator integration. Created IncomeSourcesController with CRUD operations, income form views (index/new/edit), income tab in TaxReturn show page. Integrated TaxLiabilityOrchestrator into ExportService. Enhanced export views: tax liability preview in review page, detailed breakdown in show page. Routes configured for nested income_sources. All database migrations operational, models tested, UI fully functional. Ready for Phase 5a integration testing or Phase 5b (Pension Relief).
- `2026-01-05` – Phase 5a database setup complete: Fixed SQLite jsonb→json compatibility, removed redundant migration indexes, corrected Rails 8.1 enum syntax. All 4 Phase 5a migrations running successfully. TaxBand, IncomeSource, TaxLiability, TaxCalculationBreakdown models tested and operational. 5 calculator services (IncomeAggregator, PersonalAllowanceCalculator, TaxBandCalculator, NationalInsuranceCalculator, TaxLiabilityOrchestrator) implemented. Comprehensive test specs document expected behavior.
- `2026-01-05` – Phase 5 specification created: Full UK tax calculation engine with 5 sub-phases (5a: basic income/tax/NI → 5e: advanced reliefs). Phase 5a targets employment income aggregation, Personal Allowance, tax bands (20%/40%/45%), and Class 1 NI. Modular service architecture with TaxLiability/IncomeSource/TaxCalculationBreakdown models for transparency and auditability.
- `2026-01-05` – Phase 4 export feature complete. PDF/JSON exports now support UTF-8 character encoding with sanitization for German/international documents. Text sanitization wrapper handles non-ASCII characters (ü→u, ö→o, ä→a, etc.) for Prawn PDF compatibility.
- `2026-01-03` – Phase 3 extraction pipeline complete. Ollama (gemma3:1b) integration for offline PDF text extraction and candidate box value suggestions.
- `2026-01-01` – Chose Rails + Hotwire and Docker Compose for MVP; no external calls by default.
