# NOW - Working Memory (WM)

> This file captures the current focus / sprint.
> It should always describe what we're doing right now.

<!-- SUMMARY_START -->
**Current Focus (auto-maintained by Agent):**
- Phase 3: Offline PDF extraction pipeline and review flow.
- Ollama (gemma3:1b) local integration for candidate box values.
- Validate extraction results and acceptance flow end-to-end.
<!-- SUMMARY_END -->

---

## Current Objective

Build the offline PDF extraction workflow (text extraction -> local LLM suggestions -> review/acceptance).

---

## Active Branch

- `main`

---

## What We Are Working On Right Now

- [x] Decide stack (Rails + Hotwire) and require local-only execution.
- [x] Extract a first-pass box list from the SA forms PDF.
- [x] Define box registry schema + seed plan from extracted boxes.
- [x] Draft Docker Compose + Rails skeleton for Sprint 1.
- [x] Implement encrypted Active Storage for evidence uploads.
- [x] Add PDF text extraction + Ollama suggestion pipeline and review UI.

---

## Next Small Deliverables

- Run an end-to-end extraction on a sample PDF and validate candidate mapping.
- Add minimal tests for extraction services and controller flow.
- Decide whether to add offline OCR fallback criteria.

---

## Backlog (Pending)

- [ ] Seed the box registry into the Rails DB (dev setup).
- [ ] Add the first data-entry screen for TR1/TR2.
- [ ] Validate no personal data is stored in repo artifacts.

---

## Notes / Scratchpad

- Treat PDFs as blank templates; do not store personal data in repo files.
