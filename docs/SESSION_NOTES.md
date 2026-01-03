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
