# Specification Drift Analysis (2026-01-05, updated after spec merge)

> Review of docs/spec.md vs current build after incorporating docs/dif.md.

---

## Executive Summary

**Overall Status:** Mostly aligned; remaining drift is documentation of HMRC calculation sources.

- ✅ Core offline architecture, encryption, and local LLM extraction remain aligned.
- ✅ Deterministic calculations exist (full engine still in scope).
- ✅ Template Profile + Return Workspace are implemented (admin UI + generator + field input + checklist + worksheet).
- ✅ Printable worksheet (HTML first) + PDF derived from HTML (wkhtmltopdf in production; Prawn fallback).
- ✅ Missing-items checklist implemented (value/confirmation/evidence status with field/box evidence).
- ✅ FX provenance + evidence-to-field linking are implemented (field values + boxes; exports include references).
- ✅ API surface in spec is aligned via compatibility routes (legacy paths preserved).

---

## 1. Goals Alignment (Updated Spec)

| Goal | Status | Evidence |
|------|--------|----------|
| Template-driven required-fields set from consultant pack | ✅ COMPLETE | Admin UI + template fields with required rules |
| Return Workspace per tax year | ✅ COMPLETE | Workspace generator creates FieldValues for new returns |
| "Copy to HMRC" worksheet export (HTML first, then PDF) | ✅ COMPLETE | HTML worksheet + wkhtmltopdf PDF (Prawn fallback) |
| Checklist with direct box mapping | ✅ COMPLETE | Checklist endpoint + UI with evidence status |
| Deterministic calculations based on HMRC docs | ⚠️ PARTIAL | Engine exists; HMRC basis not documented in code/spec |
| Offline LLM extraction (optional, assistive) | ✅ COMPLETE | PdfTextExtractionService + OllamaExtractionService |
| Encryption at rest for sensitive data + attachments | ✅ COMPLETE | EncryptedDiskService + ActiveRecord encryption |

**Conclusion:** Template-driven requirements are implemented; remaining gap is HMRC calculation source documentation. Core existing functionality remains aligned. ❗

---

## 2. Constraints & Invariants Compliance

| Constraint | Spec Requirement | Current Build | Status |
|-----------|-----------------|----------------|--------|
| Canonical HMRC schema | 2024-25 forms | BoxDefinitions seeded | ✅ |
| Data stays local | No outbound calls | Local-only, Ollama on localhost | ✅ |
| LLM extraction | Optional, human-in-loop | Manual review required | ✅ |
| Evidence encryption | Encrypted disk | EncryptedDiskService | ✅ |
| Template profile distinct from registry | Separate required-fields set | Admin UI + generator present | ✅ |
| Missing-items checklist pre-export | Template-based checklist | Checklist UI present with evidence status | ✅ |

---

## 3. Architecture Drift

### Spec Components (New)
```
TemplateProfile, TemplateField
ReturnWorkspace, FieldValue
EvidenceLink, FXProvenance
Worksheet Export (HTML -> PDF)
Checklist (template-based)
```

### Current Build
- Box Registry, Returns, Evidence, Extraction, Exporter (PDF/JSON) are implemented.
- Template profile + return workspace data models exist with admin UI and generator (TemplateProfile, TemplateField, ReturnWorkspace, FieldValue).
- Evidence-to-field linking implemented for template field values.
- FX provenance stored for template fields and box values.

**Conclusion:** Key new architectural components are present. ✅

---

## 4. API Surface Drift

### Spec Endpoints (New/Updated)
- Template profile:
  - GET /template_profile
  - POST/PATCH/DELETE /template_profile/fields
- Checklist:
  - GET /returns/:id/checklist
- Worksheet:
  - GET /returns/:id/worksheet (HTML)
  - GET /returns/:id/export (PDF + JSON)

### Current Build
- Template profile endpoints implemented under `/template_profile`.
- Checklist endpoint implemented under `/returns/:id/checklist` (legacy `/tax_returns/:id/checklist` remains).
- Worksheet endpoint implemented under `/returns/:id/worksheet` (legacy `/tax_returns/:id/worksheet` remains).
- Evidence endpoints implemented under `/evidence/:id` (legacy `/evidences/:id` remains).

**Conclusion:** API surface matches the spec via compatibility routes. ✅

---

## 5. Phase Status vs Updated Spec

### Phase 1b - Template Profile + Return Workspace (new)
**Spec:** Admin UI, workspace generator, checklist, HTML worksheet
**Current:** ✅ Complete (admin UI + generator + field input + checklist + worksheet + schedules/TR7 note)

### Existing Phases (1-4, 5)
**Status:** ✅ Implemented previously; still valid in scope.

---

## 6. Acceptance Criteria (Updated)

| Criterion | Status | Notes |
|-----------|--------|-------|
| Template profile via admin UI | ✅ | Admin UI implemented |
| Return Workspace mirrors template | ✅ | Generated on TaxReturn creation (no backfill) |
| Field values support evidence links + FX provenance | ✅ | Field values capture and link evidence + FX provenance |
| Missing-items checklist before export | ✅ | Checklist UI exists with evidence status |
| Worksheet export (HTML) with form/page/box + schedules + TR7 note | ✅ | HTML worksheet includes schedules and TR7 note |
| PDF export generated from HTML worksheet | ✅ | wkhtmltopdf used when available; Prawn fallback |
| Export includes evidence references + FX provenance | ✅ | HTML/PDF/JSON include FX and evidence references |
| Offline LLM extraction w/ approval | ✅ | Implemented |
| Encryption at rest | ✅ | Implemented |

---

## 7. Recommendations (Priority Order)

1. **Document HMRC basis for calculations (Medium)**
   - Tie deterministic engine to documented rules and update spec references.
2. **Workspace backfill (Low)**
   - Optional: generate workspaces for existing returns.

---

## 8. Overall Assessment

The spec update introduces a **template-driven workflow** that is now supported. Core offline and deterministic features remain aligned, with **HMRC calculation source documentation** as the main remaining gap.
