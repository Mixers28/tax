# NOW - Working Memory (WM)

> This file captures the current focus / sprint.
> It should always describe what we're doing right now.

<!-- SUMMARY_START -->
**Current Focus (auto-maintained by Agent):**
- Phase 4: PDF/JSON export generation (COMPLETE ✓)
- UTF-8 character encoding support for German filenames and international documents
- Export feature fully functional with download capability
<!-- SUMMARY_END -->

---

## Current Objective

Phase 4 complete: Users can now generate, review, and download PDF/JSON exports with proper character handling.

---

## Active Branch

- `main`

---

## Phase Completion Summary

- [x] Phase 1: Box registry schema and database setup
- [x] Phase 2: Evidence uploads and encryption
- [x] Phase 3: PDF extraction pipeline with Ollama integration
- [x] Phase 4: PDF/JSON export generation with character encoding support

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

## Next Small Deliverables

- [ ] Add comprehensive test suite for export services
- [ ] Test with actual German pay slip documents
- [ ] Add optional PDF table formatting for calculations
- [ ] Implement export history/archive management
- [ ] Add more export formats (CSV, Excel) if needed

---

## Backlog / Future Phases

- [ ] HMRC filing integration (if required)
- [ ] Export scheduling for batch operations
- [ ] Performance optimization for large exports
- [ ] Additional export format support (CSV, Excel)
- [ ] Compliance documentation and audit trail enhancement

---

## Technical Notes

- **UTF-8 Handling:** Prawn's built-in fonts support Windows-1252 only; implemented sanitization to convert non-ASCII characters to ASCII equivalents
- **Route Helpers:** Rails nested routes generate helpers with action name first (e.g., `download_pdf_tax_return_export_path`)
- **Data Integrity:** Original filenames preserved in JSON exports; PDF display uses simplified ASCII versions
- **Testing:** Verified with exports containing German character examples and multiple evidence files
