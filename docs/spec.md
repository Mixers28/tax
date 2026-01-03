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
- Local inference runtime (for example, llama.cpp or a local HTTP service) running a 1.1B parameter model.
- Runs on the same machine with no network calls.
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
- Integrate local LLM runner (1.1B model, offline).
- UI for candidate review and acceptance.
- Audit log for extraction suggestions and user confirmations.

### Phase 4 - Export and validation
- Export worksheet (PDF + JSON).
- Completeness checklist and validation rules.
- FTCR/Gift Aid/HICBC deterministic calculators.

## Acceptance Criteria
- App runs fully offline; no outbound network calls in default mode.
- Evidence files are stored on disk encrypted and cannot be read without keys.
- Sensitive DB data is encrypted at rest (document the key source and rotation plan).
- LLM extraction runs locally and produces candidate values that require user approval.
- Export output matches expected HMRC box values for a known sample dataset.

## Assumptions / Open Questions
- PDFs are text-based unless we explicitly add offline OCR; confirm whether OCR is in scope.
- Confirm the preferred local LLM runtime and model packaging approach.
