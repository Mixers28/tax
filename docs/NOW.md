# NOW - Working Memory (WM)

> This file captures the current focus / sprint.
> It should always describe what we're doing right now.

<!-- SUMMARY_START -->
**Current Focus (auto-maintained by Agent):**
- Implement Rails + Docker Compose scaffold with local-only defaults.
- Build the boxes-first registry schema and seed pipeline from extracted boxes.
- Prepare next-phase tasks for data capture UI and validation.
<!-- SUMMARY_END -->

---

## Current Objective

Prepare the boxes-first foundation and Rails + Docker scaffold for the UK Self Assessment helper.

---

## Active Branch

- `main`

---

## What We Are Working On Right Now

- [x] Decide stack (Rails + Hotwire) and require local-only execution.
- [x] Extract a first-pass box list from the SA forms PDF.
- [x] Define box registry schema + seed plan from extracted boxes.
- [x] Draft Docker Compose + Rails skeleton for Sprint 1.

---

## Next Small Deliverables

- Seed the box registry into the Rails DB (dev setup).
- Add the first data-entry screen for TR1/TR2.
- Validate no personal data is stored in repo artifacts.

---

## Notes / Scratchpad

- Treat PDFs as blank templates; do not store personal data in repo files.
