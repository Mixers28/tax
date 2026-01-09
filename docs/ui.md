# UI SPEC - Template-Driven Tax Helper

## Visual Direction
- Ledger-inspired, accountant-style layout (paper-white background, subtle ruled lines).
- Typography: serif headings (Source Serif 4) + crisp sans for UI (IBM Plex Sans).
- Palette: charcoal ink, slate accents, muted blue highlights; avoid purple.
- Status language: "Missing value", "Missing evidence", "Needs confirmation", "Complete".

## Global Layout (Future)
- **Top Bar**: Return name + tax year, global progress (e.g., 42/63), quick actions (Checklist, Worksheet, Export).
- **Left Nav**: Form/Page tree with status badges; search/filter by form/page/box.
- **Main Panel**: sectioned content by form/page; collapsible sections; sticky Save + Print View when relevant.

## 1) Template Profile Admin
**Purpose:** Define the required field set based on the consultant pack.

Layout:
- **Left Pane**: Page list (SA100 TR4, TR5, TR7; SA106 F6, etc.) with search and filters.
- **Center**: Field list table (Form/Page/Box, Label, Type, Required rule, Source).
- **Right Pane (Preview Workspace)**: Live preview of how fields will render in a Return Workspace.

Key UI Elements:
- "Add field" and "Add line-item table" actions.
- Bulk import JSON for template definitions (future).
- Inline chips for required/conditional rules.

## 2) Return Workspace (Data Entry)
**Purpose:** Fill values, attach evidence, and capture FX provenance for each required field.

Field Row Layout:
- **Left**: Box code + label.
- **Center**: Input (money/date/text) with currency selector when applicable.
- **Right**: Evidence chips + FX provenance icon + status badge.

FX Provenance Panel:
- Original amount, method (HMRC average/monthly/spot), rate, period, source link.

Evidence:
- "Attach evidence" modal.
- Evidence chips with count and last added date.

## 3) Checklist View
**Purpose:** Show missing or unconfirmed items before export.

Layout:
- Filter toggles: Missing value / Missing evidence / Needs confirmation.
- Grouped by Form/Page with jump-to-field actions.
- Summary banner with totals and readiness status.

## 4) Worksheet (Printable HTML)
**Purpose:** Accountant-style worksheet for copy to HMRC online filing.

Layout:
- Header: Client name, tax year, timestamp.
- Sections grouped by Form/Page.
- Ledger table columns: Box, Label, Value, Notes, Evidence count.
- Schedules: SA106 F6 table rows.
- TR7 Notes: auto-generated cross-reference block.

Print Mode:
- Toggle hides UI chrome (future).
- Page breaks per Form/Page (future).
- Monochrome-friendly styling.

## 5) Export & Review
**Purpose:** Validate data before generating PDF/JSON exports.

Layout:
- Summary cards: values entered, validations, evidence count.
- Checklist status + validation warnings.
- Export options: HTML print, PDF, JSON.
- Audit note: "All values confirmed by user" with timestamp.

## Future Enhancements
- **Bulk import JSON**: ingest consultant template packs into Template Profile.
- **Line-item tables**: SA106 F6 rows rendered as structured tables.
- **Print view toggle**: dedicated print mode with page breaks.
- **Client name source**: confirm whether header uses user profile or return metadata.
