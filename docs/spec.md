# SPEC - UK Self Assessment Helper

## Goals / Non-goals

### Goals
- Local-first web app that maps user inputs to HMRC SA100/SA102/SA106/SA110 boxes for tax year 2024-25.
- "Copy to HMRC" worksheet export (PDF + JSON) that is box accurate and traceable to evidence.
- Deterministic calculations only (ANI, HICBC, FTCR); no automated tax advice.
- Offline PDF data extraction using a local 1.1B parameter LLM to propose candidate values from evidence.
- Encryption at rest for all sensitive data and attachments.

### Non-goals
- No direct submission or e-filing to HMRC.
- No cloud inference or third-party services by default.
- No automated residency or treaty determination; inputs only.
- No OCR automation unless explicitly added as an offline dependency.

## Constraints / Invariants
- Canonical schema is the HMRC paper forms for 2024-25.
- Data stays local; outbound network calls are disabled by default.
- LLM extraction is offline, opt-in, and human-in-the-loop. The app must never auto-fill final values without review.
- Evidence files and derived data are encrypted at rest.
- Active Storage must use an encrypted disk-backed service for evidence files.
- No personal data is committed to the repo (seed data must be sanitized).

## Architecture

### Components
- Box Registry: FormDefinition, PageDefinition, BoxDefinition.
- Returns: TaxYear, TaxReturn, BoxValue, AuditLog.
- Evidence: Active Storage attachments plus Evidence records.
- Extraction: Offline LLM service to parse PDFs and suggest BoxValues.
- Exporter: Worksheet and JSON export with evidence links.

### LLM Extraction Service
- Local inference runtime (Ollama) running a 1.1B parameter model.
- Runs on the same machine with no outbound network calls; app talks to a local HTTP endpoint.
- Accepts PDF text or extracted text and returns structured candidates plus confidence metadata.
- All outputs are treated as suggestions and require explicit user confirmation.

## Data Flow
- Evidence upload -> Active Storage encrypted disk -> Evidence record created.
- Extraction request -> PDF text extraction (and optional offline OCR if needed) -> local LLM -> candidate fields.
- User reviews candidates -> approved values saved as BoxValue with audit entry.
- Exporter compiles Form/Page/Box values with evidence references.

## API Surface
- Evidence:
  - POST /evidence (upload)
  - GET /evidence/:id (metadata and links)
- Extraction:
  - POST /evidence/:id/extract (trigger LLM extraction)
  - GET /evidence/:id/extract (candidate results)
- Returns and boxes:
  - GET /returns/:id/boxes
  - PATCH /returns/:id/boxes/:box_definition_id
- Export:
  - GET /returns/:id/export (PDF + JSON)

## Phases + Sprint Plan (Tickets)

### Phase 1 - Boxes-first foundation (done)
- Models and migrations for box registry and returns.
- Seed pipeline from extracted HMRC box list.
- Docker Compose local scaffold.

### Phase 2 - Encrypted storage and evidence handling
- Implement Active Storage for evidence attachments.
- Add encrypted disk service for Active Storage.
- Add encryption at rest for sensitive DB columns (design and key management).
- Evidence upload UI + metadata capture.

### Phase 3 - Offline PDF extraction
- Add PDF text extraction pipeline.
- Integrate Ollama local runner (1.1B model, offline).
- UI for candidate review and acceptance.
- Audit log for extraction suggestions and user confirmations.

### Phase 4 - Export and validation
- Export worksheet (PDF + JSON).
- Completeness checklist and validation rules.
- FTCR/Gift Aid/HICBC deterministic calculators.

### Phase 5 - Full tax calculation engine
Comprehensive UK Self Assessment tax liability calculator with modular, deterministic services.

**Sub-phases:**
- **Phase 5a (MVP):** Basic employment income tax calculator
  - Income aggregation from multiple sources
  - Personal Allowance: £12,570 (withdrawal above £125,140)
  - Tax bands: 20% (basic), 40% (higher), 45% (additional)
  - Class 1 National Insurance: 8% (£12,571–£50,270), 2% (£50,271+)
  - UI: Income entry form with CRUD operations, TaxReturn integration
  - Currency support: EUR/USD input with automatic GBP conversion (cached exchange rates)
  - Export integration: Tax liability preview in review page, detailed breakdown in show page
  - Data models: TaxBand, IncomeSource, TaxLiability, TaxCalculationBreakdown
  - Architecture: Modular service classes (IncomeAggregator, PersonalAllowanceCalculator, TaxBandCalculator, NationalInsuranceCalculator, TaxLiabilityOrchestrator)

- **Phase 5b:** Pension relief, Gift Aid, Blind Allowance
- **Phase 5c:** Investment income (dividends, interest, capital gains)
- **Phase 5d:** Self-employment income and Class 2/4 NI
- **Phase 5e:** Marriage Allowance, Married Couple's Allowance, advanced reliefs

**Implementation notes:**
- All calculations are deterministic and auditable (no AI decision-making)
- Tax results are suggestions users can override before export
- Exchange rates cached in docker-compose.yml (zero external API calls)
- Calculation steps stored in database for full transparency
- 2024-25 UK tax year thresholds and rates

## Acceptance Criteria
- App runs fully offline; no outbound network calls in default mode.
- Evidence files are stored on disk encrypted and cannot be read without keys.
- Sensitive DB data is encrypted at rest (document the key source and rotation plan).
- LLM extraction runs locally and produces candidate values that require user approval.
- Export output matches expected HMRC box values for a known sample dataset.

## Assumptions / Open Questions
- PDFs are text-based unless we explicitly add offline OCR; confirm whether OCR is in scope.
- Ollama is run locally on the host (not inside the app container) for Phase 3.
