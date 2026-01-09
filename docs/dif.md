Agent brief: “Template-driven tax helper (accountant-style output)”
Desired outcome

Build a private tool that uses last year’s completed Self Assessment PDF pack (produced by a tax consultant) as a template to determine:

Which HMRC forms/pages/boxes matter for me (the “required fields set” for my situation).

How to collect those inputs each year, with evidence and FX provenance.

How to output an accountant-style worksheet that mirrors what my consultant produced: a box-by-box values list plus supporting schedules and notes (TR7 cross-references), ready to copy into HMRC online filing.

The tool must be deterministic and auditable: no guessing. If information is missing, it must show a missing-items checklist.

Inputs

A PDF template pack from a tax consultant (e.g., SA100 2025 pages TR1, TR2, TR4, TR5, TR7, TR8; SA102 E1; SA106 F1/F6; SA110 TC1).

User-entered values for the next year (employment amounts, foreign tax paid, Gift Aid totals, Child Benefit totals).

Optional evidence files (PDF/JPG/CSV) linked to specific fields/lines.

Core concept

Implement a Template Profile that represents “what my return needs”:

The template profile is a list of:

form_code (SA100/SA102/SA106/SA110)

page_code (TR4/E1/F6/TC1…)

box_code (or line item type, e.g., “SA106_F6_LINES”)

label

value_type (money/int/date/text/bool/table)

required rule (always / conditional)

This profile is derived from the template PDF once, then reused for future years.

Functional requirements
1) Template ingestion (MVP = manual mapping + later automation)

MVP approach: allow the user/agent to manually define the template profile from the consultant pack:

Add pages/boxes via a small admin UI or seed JSON.

Link each box to a meaning (e.g., “TR4 box 5 = Gift Aid payments”).

Later enhancement (optional): parse PDF text for box labels and page identifiers to pre-fill the mapping (but still require human confirmation).

Acceptance test: Template profile created for the exact pages/boxes my consultant used.

2) Year workspace

For a new tax year, the app creates a “Return Workspace” from the template profile:

every required box becomes a field to fill

every field can have:

value

note

evidence attachments

Acceptance test: New year has the same required fields as last year, with blank values.

3) Evidence + provenance

Each value supports:

attachments (e.g., German wage tax statement, donation statement)

FX conversion provenance for EUR→GBP:

original amount

method (HMRC average/monthly/spot)

rate + period + source

Acceptance test: Every foreign-currency field stores both EUR and GBP plus FX metadata.

4) Accountant-style output

Generate a Worksheet Export that looks like an accountant pack:

Section headings by form/page

A list of:

Form / Page / Box

Label

Value

Notes

Evidence count

Include schedules:

SA106 F6 table (rows for foreign tax paid)

Include TR7 note auto-generation:

if SA106 F6 exists, TR7 must reference where the income is included (e.g., SA102).

Acceptance test: Export is a single PDF/HTML view that I can use to copy values into HMRC online, and it includes the TR7 cross-reference note.

5) Missing-items checklist

If required template fields have no value/evidence (depending on rule), produce:

“missing value”

“missing evidence”

“needs confirmation” flags

Acceptance test: A checklist appears before export with actionable items.

Non-goals (MVP)

No HMRC submission integration.

No full tax computation engine (HMRC online calculates).

No residency/treaty decision-making.

Data model (minimum)

TemplateProfile

TemplateField (form/page/box + type + required rules)

ReturnWorkspace (tax year instance)

FieldValue (value + notes + scenario overrides)

Evidence + EvidenceLink

ForeignTaxLine (for SA106 F6 table rows)

GiftAidDonation (optional; otherwise input directly into TR4 totals)

Implementation steps (what the agent should build first)

Implement template profile as seed JSON + DB tables.

Build “Return Workspace” generator from template profile.

Build input UI for the listed pages/boxes.

Build export worksheet (HTML first, then PDF).

Add validations + missing-items checklist.

Add evidence attachments + linking.

Concrete template for THIS user (seed JSON idea)

Template fields to include initially:

SA102 E1: pay, UK tax taken off

SA106 F6: foreign tax paid lines (+ “income included where”)

SA100 TR4: Gift Aid total (box 5) (+ optional other charitable boxes)

SA100 TR5: Child Benefit total + children count

SA100 TR7: Any other information (auto from F6)

(Optional) SA106 F1 box 2 FTCR total

(Optional) SA110 TC1 captured fields (for reference only)

One sentence summary the agent should repeat back

“Build a template-driven form/box data capture app where last year’s consultant PDF determines the required fields, and the output is an accountant-style worksheet (box-by-box + schedules + notes) for future filings.”