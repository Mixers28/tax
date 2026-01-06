# Session Notes – Session Memory (SM)

> Rolling log of what happened in each focused work session.  
> Append-only. Do not delete past sessions.

---

## Example Entry

### 2025-12-01

**Participants:** User,VS Code Agent, Chatgpt   
**Branch:** main  

### What we worked on
- Set up local MCP-style context system.
- Added handoffkit CLI and VS Code tasks.
- Defined PROJECT_CONTEXT / NOW / SESSION_NOTES workflow.

### Files touched
- docs/PROJECT_CONTEXT.md
- docs/NOW.md
- docs/SESSION_NOTES.md
- docs/AGENT_SESSION_PROTOCOL.md
- docs/MCP_LOCAL_DESIGN.md
- handoffkit/__main__.py
- pyproject.toml
- .vscode/tasks.json

### Outcomes / Decisions
- Established start/end session ritual.
- Agents will maintain summaries and NOW.md.
- This repo will be used as a public template.

---

## Session Template (Copy/Paste for each new session)
## Recent Sessions (last 3-5)

### 2026-01-06 (Session 3 - Currency Support & Charset Fix)

**Participants:** User, Claude Code Agent
**Branch:** main

### What we worked on
- **Currency Support Implementation (Option B):** Added multi-currency support for income entry
  - Created migration: `add_currency_to_income_sources.rb` with currency and exchange_rate columns
  - Created ExchangeRateConfig initializer reading EUR_TO_GBP_RATE and USD_TO_GBP_RATE from environment
  - Updated IncomeSourcesController.income_source_params to auto-convert EUR/USD to GBP at form submission
  - Updated income form with currency selector dropdown, exchange rate input field, dynamic currency symbols
  - Added JavaScript to show system rate hint and update symbols on currency change
  - Updated docker-compose.yml with environment variables (EUR: 0.8650, USD: 1.2850)
  - Exchange rate stored in database for audit trail; all amounts normalized to GBP
- **Charset Encoding Fix:** Fixed £ symbol rendering in export calculations
  - Added `<meta charset="UTF-8">` to application.html.erb layout
  - Resolved issue where currency symbols displayed as ? instead of proper symbols

### Files touched
- web/db/migrate/20260106012931_add_currency_to_income_sources.rb (NEW)
- web/config/initializers/exchange_rates.rb (NEW)
- web/app/controllers/income_sources_controller.rb (MODIFIED - income_source_params)
- web/app/views/income_sources/_form.html.erb (MODIFIED - currency selector + JS)
- docker-compose.yml (MODIFIED - added exchange rate variables)
- web/app/views/layouts/application.html.erb (MODIFIED - added charset meta tag)
- docs/NOW.md (UPDATED)
- docs/PROJECT_CONTEXT.md (UPDATED)

### Outcomes / Decisions
- Currency support complete: Cached exchange rates in environment, zero external API calls
- Maintains local-first design principle: all rates configured in docker-compose.yml
- Exchange rate stored per income entry for audit trail and transparency
- Users can override system rate on form if needed
- All amounts normalized to GBP in database for calculation consistency
- Charset fix resolved symbol rendering issue across entire application
- Ready for Phase 5a integration testing with multi-currency income support

---

### 2026-01-05 (Session 2 - Phase 5 Planning)

**Participants:** User, Claude Code Agent
**Branch:** main

### What we worked on
- **Phase 5: Full Tax Calculation Engine Specification** - Comprehensive design for income aggregation, tax liability, and NI calculation
- Analyzed HMRC SA100 (Tax Return) and SA102 (Employment) blank forms to understand canonical box structure
- Verified blank forms already available in docs/references/ directory
- Created comprehensive Phase 5 specification document (docs/PHASE_5_SPEC.md) with:
  - Phase decomposition: 5a (basic income/tax) → 5e (advanced reliefs)
  - Data model: TaxLiability, IncomeSource, TaxCalculationBreakdown, TaxBand models
  - Calculation logic for Personal Allowance, tax bands (20%/40%/45%), Class 1 NI (8%/2%)
  - Service architecture: IncomeAggregator, PersonalAllowanceCalculator, TaxBandCalculator, etc.
  - Form prefill strategy for SA100/SA102 auto-population with calculated values
  - Database migrations for all new models
  - UI/UX changes (Income Entry, Tax Calculation Summary pages)
  - Acceptance criteria and test strategy
  - 2024-25 UK tax thresholds and rates
- Updated context documents (NOW.md, PROJECT_CONTEXT.md, SESSION_NOTES.md) to reflect Phase 5 planning

### Files touched
- docs/PHASE_5_SPEC.md - Phase 5 specification (NEW)
- docs/NOW.md - Updated with Phase 5 planning and next deliverables
- docs/PROJECT_CONTEXT.md - Added Phase 5 to changelog and links
- docs/SESSION_NOTES.md - This session entry (Phase 5 planning)

### Outcomes / Decisions
- Phase 5 specification complete and ready for review by user
- Architecture decision: Modular service classes for each calculator, enforcing separation of concerns
- Data model decision: TaxLiability records store full calculation breakdown for transparency and auditability
- Strategy decision: Auto-calculations are suggestions users can override before export (not locked)
- Phasing strategy: 5 sub-phases from basic (5a) to advanced reliefs (5e), Phase 5a is MVP for employment-only users
- Next step: Await user approval/feedback on Phase 5 specification before beginning Phase 5a implementation

---

### 2026-01-05 (Session 1 - Phase 4 Completion)

**Participants:** User, Claude Code Agent
**Branch:** main

### What we worked on
- **Phase 4: PDF/JSON Export Generation** - Complete implementation of export feature with UTF-8 character encoding support
- Fixed text sanitization for German filenames and international characters (ü→u, ö→o, ä→a, Ü→U, Ö→O, Ä→A, ß→ss)
- Implemented PDFExportService with Prawn library and text sanitization wrapper
- Implemented JSONExportService with structured data serialization (box values, validations, calculations, evidence, audit trail)
- Created review/preview page for exports before generation
- Fixed Rails nested route helpers for PDF/JSON download functionality
- Tested exports end-to-end with both PDF and JSON formats
- Updated context documents (NOW.md, PROJECT_CONTEXT.md, SESSION_NOTES.md)

### Files touched
- web/app/services/pdf_export_service.rb - PDF generation with text sanitization
- web/app/services/json_export_service.rb - JSON serialization
- web/app/services/export_service.rb - Export orchestration
- web/app/controllers/exports_controller.rb - Export controller actions
- web/app/models/export.rb - Export model helper methods
- web/app/views/exports/show.html.erb - Export detail page (fixed route helpers)
- web/app/views/exports/index.html.erb - Export list page (fixed route helpers)
- web/app/views/tax_returns/show.html.erb - Tax return page with export links (fixed route helpers)
- docs/NOW.md - Updated with Phase 4 completion
- docs/PROJECT_CONTEXT.md - Updated with Phase 4 summary
- docs/SESSION_NOTES.md - This session entry

### Outcomes / Decisions
- Phase 4 export feature is production-ready with full UTF-8 character support
- Text sanitization converts non-ASCII characters to ASCII equivalents for Prawn PDF compatibility
- Original filenames preserved in JSON exports; PDF display uses simplified ASCII versions
- Route helper naming convention: action comes first in nested resources (download_pdf_tax_return_export_path)
- Exports include: title page, box values, validation summary, tax calculations, evidence files, and integrity hash

### 2026-01-03

**Participants:** User, Codex Agent  
**Branch:** main  

### What we worked on
- Added encrypted Active Storage service fixes and evidence upload flow improvements.
- Implemented Phase 3 extraction pipeline: PDF text extraction, Ollama integration, review/accept UI, and audit logs.
- Added draft tax return creation path for evidence uploads and updated docs/README.
- Resolved runtime errors in encryption, checksum verification, and file digest timing.

### Files touched
- docs/NOW.md
- docs/PROJECT_CONTEXT.md
- docs/spec.md
- web/README.md
- web/config/routes.rb
- web/lib/active_storage/service/encrypted_disk_service.rb
- web/app/controllers/evidences_controller.rb
- web/app/controllers/extraction_runs_controller.rb
- web/app/controllers/tax_returns_controller.rb
- web/app/models/evidence.rb
- web/app/models/extraction_run.rb
- web/app/services/ollama_extraction_service.rb
- web/app/services/pdf_text_extraction_service.rb
- web/app/views/evidences/new.html.erb
- web/app/views/evidences/show.html.erb
- web/db/migrate/20260101091200_create_extraction_runs.rb

### Outcomes / Decisions
- Ollama (gemma3:1b) selected as the local LLM runtime for Phase 3.
- Encrypted Active Storage runs via a custom service under `web/lib/active_storage/service`.

### 2026-01-01 (Session 2)

**Participants:** User, Codex Agent  
**Branch:** main  

### What we worked on
- Generated a Rails app scaffold (in `web/`) and added box registry models + migrations.
- Added seed logic to load box definitions from the extracted JSON.
- Added a local Docker Compose dev setup for the Rails app.
- Updated NOW to reflect Phase 1 completion and next steps.

### Files touched
- docs/NOW.md
- docs/SESSION_NOTES.md
- web/Gemfile
- web/db/seeds.rb
- web/db/migrate/20260101090000_create_tax_years.rb
- web/db/migrate/20260101090100_create_tax_returns.rb
- web/db/migrate/20260101090200_create_form_definitions.rb
- web/db/migrate/20260101090300_create_page_definitions.rb
- web/db/migrate/20260101090400_create_box_definitions.rb
- web/db/migrate/20260101090500_create_box_values.rb
- web/db/migrate/20260101090600_create_evidences.rb
- web/db/migrate/20260101090700_create_evidence_box_values.rb
- web/db/migrate/20260101090800_create_audit_logs.rb
- web/app/models/tax_year.rb
- web/app/models/tax_return.rb
- web/app/models/form_definition.rb
- web/app/models/page_definition.rb
- web/app/models/box_definition.rb
- web/app/models/box_value.rb
- web/app/models/evidence.rb
- web/app/models/evidence_box_value.rb
- web/app/models/audit_log.rb
- docker-compose.yml
- web/Dockerfile.dev

### Outcomes / Decisions
- Phase 1 implemented: boxes-first registry schema, seed pipeline, and Docker Compose scaffolding.

### 2026-01-01

**Participants:** User, Codex Agent  
**Branch:** main  

### What we worked on
- Confirmed Rails + Hotwire stack, Docker Compose from Sprint 1, and local-only isolation.
- Extracted a first-pass box list from the SA forms PDF for templating.
- Sanitized extracted text to avoid storing personal data.
- Updated PROJECT_CONTEXT and NOW to reflect the tax app focus and next steps.

### Files touched
- docs/PROJECT_CONTEXT.md
- docs/NOW.md
- docs/SESSION_NOTES.md
- docs/references/sa-forms-2025-boxes-first-pass.json
- docs/references/sa-forms-2025-boxes-first-pass.md
- docs/references/sa-forms-2025-redacted.txt

### Outcomes / Decisions
- Rails + Hotwire selected; Docker Compose required from Sprint 1; no external calls by default.
- Box definitions extracted for SA forms to seed a boxes-first registry.

### 2025-12-01 (Session 2)

**Participants:** User, Codex Agent  
**Branch:** main  

### What we worked on
- Re-read PROJECT_CONTEXT, NOW, and SESSION_NOTES to prep session handoff.
- Tightened the summaries in PROJECT_CONTEXT.md and NOW.md to mirror the current project definition.
- Reconfirmed the immediate tasks: polish docs, add an example project, and test on a real repo.

### Files touched
- docs/PROJECT_CONTEXT.md
- docs/NOW.md
- docs/SESSION_NOTES.md

### Outcomes / Decisions
- Locked the near-term plan around doc polish, example walkthrough, and single-repo validation.
- Still waiting on any additional stakeholder inputs before expanding scope.

### 2025-12-01

**Participants:** User, Codex Agent  
**Branch:** main  

### What we worked on
- Reviewed the memory docs to confirm expectations for PROJECT_CONTEXT, NOW, and SESSION_NOTES.
- Updated NOW.md and PROJECT_CONTEXT.md summaries to reflect that real project data is still pending.
- Highlighted the need for stakeholder inputs before populating concrete tasks or deliverables.

### Files touched
- docs/PROJECT_CONTEXT.md
- docs/NOW.md
- docs/SESSION_NOTES.md

### Outcomes / Decisions
- Documented that the repo currently serves as a template awaiting real project data.
- Set the short-term focus on collecting actual objectives and backlog details.

### [DATE – e.g. 2025-12-02]

**Participants:** [You, VS Code Agent, other agents]  
**Branch:** [main / dev / feature-x]  

### What we worked on
- 

### Files touched
- 

### Outcomes / Decisions
-

## Archive (do not load by default)
...
