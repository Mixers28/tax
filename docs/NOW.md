# NOW - Working Memory (WM)

> This file captures the current focus / sprint.
> It should always describe what we're doing right now.

<!-- SUMMARY_START -->
**Current Focus (auto-maintained by Agent):**
- Phase 4: PDF/JSON export generation (COMPLETE ✓)
- Phase 5: Full tax calculation engine specification (PLANNED ✓)
- Ready to begin Phase 5a implementation: basic income aggregation and tax liability calculation
<!-- SUMMARY_END -->

---

## Current Objective

Phase 4 complete. Phase 5 specification created: Full UK tax calculation engine (income aggregation, tax liability, NI). Starting with Phase 5a (basic employment income + tax bands + Class 1 NI).

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

## Next Small Deliverables (Phase 5a)

- [ ] Phase 5a: Income aggregation from P60 (employment income)
- [ ] Phase 5a: Personal Allowance calculation
- [ ] Phase 5a: Tax band calculator (20%, 40%, 45%)
- [ ] Phase 5a: Class 1 National Insurance calculator
- [ ] Phase 5a: Tax calculation breakdown UI page
- [ ] Phase 5a: Form prefill with calculated values
- [ ] Phase 5a: Comprehensive unit tests for all calculators

---

## Backlog / Future Phases

- [ ] Phase 5b: Pension relief, Gift Aid, Blind Allowance
- [ ] Phase 5c: Investment income (dividends, interest, capital gains)
- [ ] Phase 5d: Self-employment and Class 2/4 NI
- [ ] Phase 5e: Marriage Allowance, Married Couple's Allowance, advanced reliefs
- [ ] Export test suite for export services
- [ ] HMRC filing integration (if required)
- [ ] Additional export format support (CSV, Excel)

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
