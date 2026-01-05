# NOW - Working Memory (WM)

> This file captures the current focus / sprint.
> It should always describe what we're doing right now.

<!-- SUMMARY_START -->
**Current Focus (auto-maintained by Agent):**
- Phase 4: PDF/JSON export generation (COMPLETE ✓)
- Phase 5: Full tax calculation engine specification (COMPLETE ✓)
- Phase 5a: Basic employment income tax calculator (COMPLETE ✓)
- Ready to integrate Phase 5a with export feature and begin Phase 5b
<!-- SUMMARY_END -->

---

## Current Objective

Phase 5a complete: Basic employment income tax calculator fully implemented with 4 modular calculator services, 4 new models, database migrations, and comprehensive test documentation. Ready for Phase 5b (pension relief) or export feature integration.

---

## Active Branch

- `main`

---

## Phase Completion Summary

- [x] Phase 1: Box registry schema and database setup
- [x] Phase 2: Evidence uploads and encryption
- [x] Phase 3: PDF extraction pipeline with Ollama integration
- [x] Phase 4: PDF/JSON export generation with character encoding support
- [x] Phase 5: Specification document for full tax calculation engine
- [x] Phase 5a: Basic employment income tax calculator (MVP)

### Phase 4 Export Feature (2026-01-05)

**Completed:**
- [x] PDF export with Prawn library (text sanitization for UTF-8 compatibility)
- [x] JSON export with structured data serialization
- [x] Review/preview page with validation summaries
- [x] Download functionality with correct route helpers
- [x] Character encoding for German/international documents
- [x] Text sanitization wrapper (ü→u, ö→o, ä→a, ß→ss, etc.)
- [x] Export sections: title page, box values, validation, calculations, evidence

---

## Phase 5a Completion Summary (COMPLETE ✓)

- [x] Income aggregation from multiple P60s (IncomeAggregator service)
- [x] Personal Allowance calculation: £12,570 with withdrawal above £125,140
- [x] Tax band calculator: 20%, 40%, 45% all three bands working correctly
- [x] Class 1 National Insurance: 8% (£12,571–£50,270) and 2% (£50,271+)
- [x] TaxBand model: 2024-25 thresholds with auto-defaults
- [x] IncomeSource model: Track income from all sources
- [x] TaxLiability model: Store complete calculation results
- [x] TaxCalculationBreakdown model: Audit trail of all calculation steps
- [x] TaxLiabilityOrchestrator: Master calculator orchestrator
- [x] Database migrations: Create all new tables
- [x] Comprehensive test specs: 4 test files with documented scenarios
- [x] PHASE_5A_README.md: Complete architecture and usage documentation

---

## Backlog / Next Phases

- [ ] **Phase 5a Integration:** Wire Phase 5a calculator into export feature (show calculations in exports)
- [ ] **Phase 5a UI:** Create income entry form and tax calculation summary page
- [ ] Phase 5b: Pension relief, Gift Aid, Blind Allowance calculators
- [ ] Phase 5c: Investment income (dividends, interest, capital gains)
- [ ] Phase 5d: Self-employment income and Class 2/4 NI
- [ ] Phase 5e: Marriage Allowance, Married Couple's Allowance, advanced reliefs
- [ ] Test Infrastructure: Set up RSpec or Minitest framework for running calculator specs
- [ ] HMRC filing integration (if required)
- [ ] Additional export formats (CSV, Excel)

---

## Technical Notes

### Phase 4 (Completed)
- **UTF-8 Handling:** Prawn's built-in fonts support Windows-1252 only; implemented sanitization to convert non-ASCII characters to ASCII equivalents
- **Route Helpers:** Rails nested routes generate helpers with action name first (e.g., `download_pdf_tax_return_export_path`)
- **Data Integrity:** Original filenames preserved in JSON exports; PDF display uses simplified ASCII versions
- **Testing:** Verified with exports containing German character examples and multiple evidence files

### Phase 5 Planning
- **Tax Calculation Strategy:** Modular service classes per calculator (IncomeAggregator, PersonalAllowanceCalculator, TaxBandCalculator, etc.)
- **Data Model:** New TaxLiability, IncomeSource, TaxCalculationBreakdown, TaxBand models
- **2024-25 Thresholds:** PA £12,570, Basic 20% up to £50,270, Higher 40% to £125,140, Additional 45%+
- **NI Logic:** Class 1 at 8% (£12,571–£50,270) and 2% (£50,271+)
- **User Approval:** Auto-calculations as suggestions, users can override before export
- **See:** docs/PHASE_5_SPEC.md for full specification
