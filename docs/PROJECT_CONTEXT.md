# Project Context – Long-Term Memory (LTM)

> High-level design, tech decisions, constraints for this project.  
> This is the **source of truth** for agents and humans.

<!-- SUMMARY_START -->
**Summary (auto-maintained by Agent):**
- Local-first web app for UK Self Assessment 2024-25 using HMRC paper forms as the canonical schema.
- Rails + SQLite + Docker Compose, no external calls, data encrypted at rest.
- Phase 4 complete: PDF/JSON export generation with UTF-8 character encoding.
- Phase 5 spec complete: Full tax calculation engine design (5 sub-phases).
- Phase 5a/5b/5c/5d/5e complete: Unified tax calculation engine operational. All Phase 5a-5e features integrated: employment income, pension relief, gift aid, blind allowance, furnished property relief, HICBC, Class 2/4 NI, trading allowance, marriage allowance, married couple's allowance, dividend allowance, personal savings allowance.
- Phase 1b alignment complete: Template profile admin UI + workspace generator + field input + checklist + worksheet (schedules/TR7) + FX provenance capture/export.
- Phase 6 alignment complete: Spec-compatible API routes added for returns/evidence/checklist/worksheet/export/boxes.
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
- Template profile and return workspace: TemplateProfile, TemplateField, ReturnWorkspace, FieldValue with admin UI, generator, field input, checklist, FX provenance capture/export, and worksheet schedules/TR7 note.
- Unified tax calculation engine (Phase 5a/5b/5c/5d/5e):
  - **TaxCalculations:: namespace** for automatic calculations (IncomeAggregator, PersonalAllowanceCalculator, TaxBandCalculator, NationalInsuranceCalculator, PensionReliefCalculator, GiftAidCalculator, FurnishedPropertyCalculator, HighIncomeChildBenefitCalculator, TradingAllowanceCalculator, MarriageAllowanceCalculator, MarriedCouplesAllowanceCalculator, DividendAllowanceCalculator, SavingsAllowanceCalculator, InvestmentIncomeTaxCalculator)
  - **TaxLiabilityOrchestrator** orchestrates all calculators in sequence for employment, rental, pension, gift aid, self-employment, advanced relief, and investment income
  - **Calculators:: namespace** for form box validation and export value preparation only
  - **Phase 5d UI pattern**: Relief cards with simple toggle/checkbox controls; conditional form visibility via JavaScript
  - **Phase 5e Integration**: Investment income calculators automatically process dividends and interest without UI changes (uses existing IncomeSource enum types)
- Exporter generates "Copy to HMRC" worksheet (PDF + JSON) with full tax calculation summaries including all Phase 5a-5e features.

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
- `2026-01-09` – **Export annotations added:** Worksheet and PDF fallback now include evidence references and FX provenance summaries. PDF prefers wkhtmltopdf but includes annotations via Prawn fallback.
- `2026-01-06` – **Phase 5e complete:** Implemented investment income tax calculations: Dividend Allowance (£500 tax-free with special rates 8.75%/33.75%/39.35%), Personal Savings Allowance (£1,000/£500/£0 based on marginal rate), and Investment Income Tax Calculator. Created three new service classes (DividendAllowanceCalculator, SavingsAllowanceCalculator, InvestmentIncomeTaxCalculator) following Phase 5a-5d patterns. Updated IncomeAggregator to include dividends and interest in total income. Integrated Phase 5e calculators into TaxLiabilityOrchestrator after Phase 5d. Added 11 fields to tax_liabilities table via migration. Extended TaxLiability summary method and ExportService with 13 new calculation steps (41+ total). Non-breaking implementation: automatically processes investment income without UI changes using existing IncomeSource enums.

- `2026-01-06` – **BUGFIX: TaxLiabilityOrchestrator HICBC method call error fixed:** Resolved critical bug where HICBC calculator was being called with incorrect argument (gross_income), causing entire tax liability calculation chain to fail. Method was corrected to call calculate() with no arguments. Verified fix end-to-end: PDF exports now show complete calculation breakdown including Total Gross Income, Personal Allowance, Taxable Income, Income Tax, National Insurance, and Phase 5a-5d reliefs. All Phase 5a-5d features confirmed operational.

- `2026-01-06` – **Phase 5d complete:** Implemented three advanced UK tax reliefs: Trading Allowance (£1,000 simplified expenses), Marriage Allowance (£1,260 PA transfer between spouses), and Married Couple's Allowance (up to £1,108 tax relief). Created three new calculators (TradingAllowanceCalculator, MarriageAllowanceCalculator, MarriedCouplesAllowanceCalculator) integrated into TaxLiabilityOrchestrator. Added relief cards to Tax Reliefs UI with toggle/checkbox controls and conditional form visibility via JavaScript. Enforced mutual exclusivity between Marriage Allowance and MCA at model validation level. All Phase 5a-5d features seamlessly integrated into unified export with full calculation breakdowns.
- `2026-01-06` – **Phase 5b & 5c unified:** Integrated all tax relief calculators into TaxLiabilityOrchestrator. Created PensionReliefCalculator (£80→£100 gross-up, £60k annual allowance), GiftAidCalculator (band extension), FurnishedPropertyCalculator (50% FTCR), HighIncomeChildBenefitCalculator (1% charge above £60k). Extended NationalInsuranceCalculator with Class 2 (£163.80) and Class 4 (8%/2% tiered) NI. All Phase 5a-5c features now automatically integrated and seamless. Removed redundant Calculations UI tab.
- `2026-01-06` – **Currency support completed:** Implemented Option B (cached exchange rates). EUR/USD income now converts to GBP at form submission. ExchangeRateConfig reads rates from docker-compose.yml environment variables (EUR_TO_GBP_RATE: 0.8650, USD_TO_GBP_RATE: 1.2850). Exchange rate stored in database for audit trail. All amounts normalized to GBP for calculation consistency. Zero external API calls - maintains local-first design. Users can override rates on form if needed.
- `2026-01-06` – **PDF export symbol fix:** Fixed currency symbol rendering in PDF exports (£€$¥₹). Updated sanitize_text regex to preserve currency symbols while still converting problematic non-ASCII characters. Exports now show "£42,896" instead of "?42,896".
- `2026-01-06` – Phase 5a fully complete: Income entry UI + calculator integration. Created IncomeSourcesController with CRUD operations, income form views (index/new/edit), income tab in TaxReturn show page. Integrated TaxLiabilityOrchestrator into ExportService. Enhanced export views: tax liability preview in review page, detailed breakdown in show page. Routes configured for nested income_sources. All database migrations operational, models tested, UI fully functional. Ready for Phase 5a integration testing or Phase 5b (Pension Relief).
- `2026-01-05` – Phase 5a database setup complete: Fixed SQLite jsonb→json compatibility, removed redundant migration indexes, corrected Rails 8.1 enum syntax. All 4 Phase 5a migrations running successfully. TaxBand, IncomeSource, TaxLiability, TaxCalculationBreakdown models tested and operational. 5 calculator services (IncomeAggregator, PersonalAllowanceCalculator, TaxBandCalculator, NationalInsuranceCalculator, TaxLiabilityOrchestrator) implemented. Comprehensive test specs document expected behavior.
- `2026-01-05` – Phase 5 specification created: Full UK tax calculation engine with 5 sub-phases (5a: basic income/tax/NI → 5e: advanced reliefs). Phase 5a targets employment income aggregation, Personal Allowance, tax bands (20%/40%/45%), and Class 1 NI. Modular service architecture with TaxLiability/IncomeSource/TaxCalculationBreakdown models for transparency and auditability.
- `2026-01-05` – Phase 4 export feature complete. PDF/JSON exports now support UTF-8 character encoding with sanitization for German/international documents. Text sanitization wrapper handles non-ASCII characters (ü→u, ö→o, ä→a, etc.) for Prawn PDF compatibility.
- `2026-01-03` – Phase 3 extraction pipeline complete. Ollama (gemma3:1b) integration for offline PDF text extraction and candidate box value suggestions.
- `2026-01-01` – Chose Rails + Hotwire and Docker Compose for MVP; no external calls by default.
