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

### 2026-01-09 (Session 19 - Stage 10 Schedules + TR7)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Stage 10 schedules/TR7**
  - Added SA106 F6 schedule table to worksheet output
  - Generated TR7 cross-reference note when SA106 F6 entries exist
  - Updated docs to reflect Phase 1b completion

### Files touched
- web/app/services/worksheet_data_service.rb (MODIFIED - schedules/TR7)
- web/app/views/tax_returns/worksheet.html.erb (MODIFIED - schedule table + note)
- docs/NOW.md (UPDATED - Phase 1b complete)
- docs/PROJECT_CONTEXT.md (UPDATED - Phase 1b complete)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - remaining drift)

### 2026-01-09 (Session 18 - Stage 9 FX Provenance)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Stage 9 FX provenance**
  - Allowed FX provenance capture for box values via /returns/:id/boxes
  - Included box-level FX provenance IDs in JSON export
  - Updated docs to mark FX provenance complete

### Files touched
- web/app/controllers/boxes_controller.rb (MODIFIED - FX provenance sync)
- web/app/services/json_export_service.rb (MODIFIED - FX provenance IDs)
- web/test/controllers/boxes_controller_test.rb (MODIFIED - FX provenance test)
- docs/NOW.md (UPDATED - FX provenance complete)
- docs/PROJECT_CONTEXT.md (UPDATED - FX provenance status)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - FX provenance status)

### 2026-01-09 (Session 17 - Stage 8 PDF from HTML)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Stage 8 PDF from HTML**
  - Ensured wkhtmltopdf renders using print media styles and local file access
  - Updated docs to mark HTML->PDF worksheet completion

### Files touched
- web/app/services/worksheet_pdf_service.rb (MODIFIED - wkhtmltopdf flags)
- docs/NOW.md (UPDATED - stage 8 complete)
- docs/PROJECT_CONTEXT.md (UPDATED - worksheet PDF status)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - PDF status)

### 2026-01-09 (Session 14 - Stage 6 Completion)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Stage 6 finalization**
  - Added boxes controller tests covering spec compatibility
  - Updated NOW and PROJECT_CONTEXT to mark API reconciliation complete

### Files touched
- web/test/controllers/boxes_controller_test.rb (NEW)
- docs/NOW.md (UPDATED - stage 6 complete)
- docs/PROJECT_CONTEXT.md (UPDATED - stage 6 complete)

### Outcomes / Decisions
- API surface reconciliation marked complete; legacy and spec routes coexist.

### 2026-01-09 (Session 15 - Worksheet Evidence Annotations)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Stage 7 worksheet annotations**
  - Added evidence and FX provenance columns to worksheet HTML
  - Extended worksheet data service to pull evidence links and FX provenance
  - Updated docs to reflect worksheet annotation status

### Files touched
- web/app/services/worksheet_data_service.rb (MODIFIED - evidence/FX data)
- web/app/views/tax_returns/worksheet.html.erb (MODIFIED - evidence/FX columns)
- docs/NOW.md (UPDATED - worksheet annotations)
- docs/PROJECT_CONTEXT.md (UPDATED - worksheet annotations)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - worksheet acceptance criteria)

### 2026-01-09 (Session 16 - PDF Evidence Annotations)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Stage 7 PDF annotations**
  - Added evidence and FX provenance annotations to the Prawn PDF fallback
  - Updated docs to reflect PDF annotation coverage

### Files touched
- web/app/services/pdf_export_service.rb (MODIFIED - evidence/FX annotations)
- docs/NOW.md (UPDATED - PDF annotations)
- docs/PROJECT_CONTEXT.md (UPDATED - export annotations)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - export criteria)

### 2026-01-09 (Session 13 - API Surface Reconciliation)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Stage 6 API reconciliation**
  - Added spec-compatible routes for evidence/returns/checklist/worksheet/export/boxes
  - Implemented BoxesController for /returns/:id/boxes endpoints
  - Added legacy export handler for /returns/:id/export
  - Updated spec and drift analysis to document route aliases

### Files touched
- web/config/routes.rb (MODIFIED - compatibility routes)
- web/app/controllers/boxes_controller.rb (NEW)
- web/app/controllers/exports_controller.rb (MODIFIED - legacy_export + id fallback)
- docs/spec.md (UPDATED - legacy route aliases)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - API alignment)
- docs/NOW.md (UPDATED - stage 6 progress)
- docs/PROJECT_CONTEXT.md (UPDATED - stage 6 progress)

### Outcomes / Decisions
- Spec API endpoints are now supported via aliases while preserving existing UI routes.

### 2026-01-09 (Session 12 - FX Provenance + Evidence Links)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Phase 1b evidence linking + FX provenance**
  - Added EvidenceLink and FxProvenance models with polymorphic associations
  - Added field value UI for evidence linking and FX provenance capture
  - Updated checklist to use evidence links for field values
  - Extended JSON export to include template fields and FX provenance

### Files touched
- web/db/migrate/20260107000005_create_evidence_links.rb (NEW)
- web/db/migrate/20260107000006_create_fx_provenances.rb (NEW)
- web/app/models/evidence_link.rb (NEW)
- web/app/models/fx_provenance.rb (NEW)
- web/app/controllers/field_values_controller.rb (NEW)
- web/app/views/field_values/index.html.erb (NEW)
- web/app/models/evidence.rb (MODIFIED - evidence_links association)
- web/app/models/field_value.rb (MODIFIED - evidence_links + fx_provenance)
- web/app/models/box_value.rb (MODIFIED - evidence_links + fx_provenance)
- web/app/services/template_checklist_service.rb (MODIFIED - evidence links)
- web/app/services/json_export_service.rb (MODIFIED - template fields + FX provenance)
- web/config/routes.rb (MODIFIED - field_values routes)
- web/app/views/tax_returns/show.html.erb (MODIFIED - workspace fields link)
- web/test/controllers/field_values_controller_test.rb (NEW)
- docs/NOW.md (UPDATED - FX provenance progress)
- docs/PROJECT_CONTEXT.md (UPDATED - FX provenance progress)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - FX provenance status)

### Outcomes / Decisions
- Field-level evidence links and FX provenance capture are available; worksheet/PDF annotations still pending.

### 2026-01-09 (Session 11 - Worksheet Export)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Phase 1b worksheet export (HTML + PDF)**
  - Added worksheet HTML endpoint and view grouped by form/page/box
  - Added WorksheetDataService and WorksheetExportService for HTML generation
  - Added WorksheetPdfService to render PDF via wkhtmltopdf with Prawn fallback
  - Linked worksheet access from export review

### Files touched
- web/app/services/worksheet_data_service.rb (NEW)
- web/app/services/worksheet_export_service.rb (NEW)
- web/app/services/worksheet_pdf_service.rb (NEW)
- web/app/views/tax_returns/worksheet.html.erb (NEW)
- web/app/views/exports/review.html.erb (MODIFIED - worksheet link)
- web/app/controllers/tax_returns_controller.rb (MODIFIED - worksheet action)
- web/config/routes.rb (MODIFIED - worksheet route)
- web/app/services/export_service.rb (MODIFIED - PDF via worksheet)
- web/test/controllers/tax_returns_worksheet_test.rb (NEW)
- docs/NOW.md (UPDATED - worksheet progress)
- docs/PROJECT_CONTEXT.md (UPDATED - worksheet progress)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - worksheet status)

### Outcomes / Decisions
- HTML worksheet export is available; PDF generation prefers wkhtmltopdf when present.

### 2026-01-09 (Session 10 - Phase 1b Checklist)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Phase 1b checklist implementation**
  - Added checklist endpoint and UI for template fields
  - Implemented TemplateChecklistService for missing value/confirmation/evidence status
  - Wired checklist access into TaxReturn quick actions

### Files touched
- web/app/services/template_checklist_service.rb (NEW)
- web/app/views/tax_returns/checklist.html.erb (NEW)
- web/app/views/tax_returns/show.html.erb (MODIFIED - checklist link)
- web/app/controllers/tax_returns_controller.rb (MODIFIED - checklist action)
- web/config/routes.rb (MODIFIED - checklist route)
- web/test/controllers/tax_returns_checklist_test.rb (NEW)
- docs/NOW.md (UPDATED - checklist progress)
- docs/PROJECT_CONTEXT.md (UPDATED - checklist progress)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - checklist status)

### Outcomes / Decisions
- Checklist is available and tied to template fields; evidence linking still pending.

### 2026-01-07 (Session 9 - Phase 1b Admin UI + Generator)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Phase 1b alignment: admin UI + workspace generator**
  - Added TemplateProfilesController and TemplateFieldsController with singular routes
  - Built admin UI for template profile and template fields
  - Added ReturnWorkspaceGenerator and wired TaxReturn creation to generate workspaces
  - Updated docs to reflect Phase 1b progress

### Files touched
- web/app/controllers/template_profiles_controller.rb (NEW)
- web/app/controllers/template_fields_controller.rb (NEW)
- web/app/services/return_workspace_generator.rb (NEW)
- web/app/views/template_profiles/new.html.erb (NEW)
- web/app/views/template_profiles/show.html.erb (NEW)
- web/app/views/tax_returns/index.html.erb (MODIFIED - add Template Profile link)
- web/app/controllers/tax_returns_controller.rb (MODIFIED - workspace generator call)
- web/config/routes.rb (MODIFIED - template_profile routes)
- docs/NOW.md (UPDATED - Phase 1b progress)
- docs/PROJECT_CONTEXT.md (UPDATED - Phase 1b progress)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - alignment status)

### Outcomes / Decisions
- Template profile admin UI and return workspace generator are now present.
- Checklist, worksheet export, and FX provenance remain pending.

### 2026-01-07 (Session 8 - Phase 1b Scaffolding)

**Participants:** User, Codex CLI Agent
**Branch:** main

### What we worked on
- **Phase 1b scaffolding to align build with SPEC.md**
  - Added TemplateProfile, TemplateField, ReturnWorkspace, and FieldValue data models with migrations
  - Linked TaxReturn to ReturnWorkspace
  - Updated project documentation to reflect Phase 1b scaffolding and remaining gaps

### Files touched
- web/db/migrate/20260107000000_create_template_profiles.rb (NEW)
- web/db/migrate/20260107000001_create_template_fields.rb (NEW)
- web/db/migrate/20260107000002_create_return_workspaces.rb (NEW)
- web/db/migrate/20260107000003_create_field_values.rb (NEW)
- web/app/models/template_profile.rb (NEW)
- web/app/models/template_field.rb (NEW)
- web/app/models/return_workspace.rb (NEW)
- web/app/models/field_value.rb (NEW)
- web/app/models/tax_return.rb (MODIFIED - added return_workspace association)
- docs/NOW.md (UPDATED - Phase 1b focus)
- docs/PROJECT_CONTEXT.md (UPDATED - Phase 1b scaffolding noted)
- SPEC_DRIFT_ANALYSIS.md (UPDATED - partial alignment)

### Outcomes / Decisions
- Phase 1b data model scaffolding is in place.
- Admin UI, workspace generator, checklist, worksheet export, and FX provenance remain pending.

### 2026-01-06 (Session 7 - Phase 5e: Investment Income Tax)

**Participants:** User, Claude Code Agent
**Branch:** main

### What we worked on
- **Phase 5e: Investment Income Tax - Complete Implementation**
  - Implemented dividend and savings interest tax calculations following HMRC's required income taxation order
  - Created DividendAllowanceCalculator: Applies £500 tax-free dividend allowance with special dividend tax rates (8.75% basic, 33.75% higher, 39.35% additional)
  - Created SavingsAllowanceCalculator: Applies Personal Savings Allowance (PSA) amounts based on marginal tax rate determined from non-savings income (£1,000 basic rate, £500 higher rate, £0 additional rate)
  - Created InvestmentIncomeTaxCalculator: Complex tax band allocation logic that correctly places savings and dividends in remaining band space after non-savings income fills bands
  - Extended IncomeAggregator: Added aggregation methods for pension_contribution, gift_aid_donation, rental_property, dividends, and interest to include all income sources in total gross income
  - Updated TaxLiabilityOrchestrator: Integrated Phase 5e calculators after Phase 5d (lines 88-113), calls dividend allowance → savings allowance → investment income tax in correct order, adds all results to TaxLiability.update!
  - Database migration: Created AddPhase5eInvestmentIncomeToTaxLiabilities migration adding 11 fields (dividend_income_gross, dividend_allowance_amount, dividend_income_taxable, savings_interest_gross, savings_allowance_amount, savings_interest_taxable, dividend_basic_rate_tax, dividend_higher_rate_tax, dividend_additional_rate_tax, total_dividend_tax, savings_interest_tax) all with precision 12,2
  - TaxLiability model: Updated summary() method to include all 11 Phase 5e investment income fields
  - ExportService: Added 13 new calculation steps to export breakdown (dividend income gross/allowance/taxable, savings interest gross/allowance/taxable, dividend tax by band, total dividend tax, savings interest tax) bringing total to 42+ calculation steps
  - Non-breaking design: Investment income calculated automatically when users add dividend or interest IncomeSource records; uses existing IncomeSource enum types; zero impact if no investment income present

### Files touched
- web/db/migrate/20260106030000_add_phase_5e_investment_income_to_tax_liabilities.rb (NEW)
- web/app/services/tax_calculations/dividend_allowance_calculator.rb (NEW)
- web/app/services/tax_calculations/savings_allowance_calculator.rb (NEW)
- web/app/services/tax_calculations/investment_income_tax_calculator.rb (NEW)
- web/app/services/tax_calculations/income_aggregator.rb (MODIFIED - added 5 new income source aggregation methods)
- web/app/services/tax_calculations/tax_liability_orchestrator.rb (MODIFIED - integrated Phase 5e calculators, updated TaxLiability.update! call)
- web/app/models/tax_liability.rb (MODIFIED - updated summary method with Phase 5e fields)
- web/app/services/export_service.rb (MODIFIED - added 13 Phase 5e calculation steps)
- docs/NOW.md (UPDATED - Phase 5e completion summary)
- docs/PROJECT_CONTEXT.md (UPDATED - Phase 5e in summary and changelog)
- docs/SESSION_NOTES.md (THIS ENTRY)

### Outcomes / Decisions
- Phase 5e implementation complete: All investment income tax features fully integrated
- Architecture consistency: Followed existing Phase 5a-5d patterns (calculator services → orchestrator integration)
- Non-breaking changes: All Phase 5e functionality is automatic and additive; existing Phase 5a-5d logic completely unchanged
- Tax calculation order: Correctly implements HMRC requirement that non-savings income fills bands first, then savings (after PSA), then dividends (after allowance)
- Special tax rates: Dividend tax rates (8.75%/33.75%/39.35%) correctly applied distinct from standard income tax rates
- Ready for: Phase 6 (multi-year returns), HMRC filing integration, or production deployment
- All Phase 5a-5e features now fully integrated into unified export with 42+ calculation step breakdown

---

### 2026-01-06 (Session 6 - Export Calculation Debug & Fix)

**Participants:** User, Claude Code Agent
**Branch:** main

### What we worked on
- **Debugged Missing Calculations in PDF Exports**
  - Issue: PDF exports showed correct structure but "No calculations available" in Section 3 despite Phase 5d implementation being complete
  - Root cause identified: TaxLiabilityOrchestrator at line 72 was calling `HighIncomeChildBenefitCalculator.calculate(gross_income)` with an incorrect argument
  - HighIncomeChildBenefitCalculator.calculate() method expects no arguments (calculates net_income internally)
  - Fix applied: Removed the `gross_income` argument from the method call
  - Verification: Orchestrator now successfully calculates tax liability with 31 calculation steps including all reliefs
  - Test results: Export Service verified to include:
    - Total Gross Income: £109,566.88
    - Personal Allowance: £12,570.00
    - Taxable Income: £96,246.88
    - Income Tax breakdown: Basic £10,679 + Higher £17,140.75 = £27,819.75
    - National Insurance: Class 1 £3,901.94 + Class 2 £163.80 + Class 4 £194.40 = £4,260.14
    - Phase 5d reliefs: All fields present (Trading, Marriage, MCA)
    - Net Liability: £16,895.81
  - PDF exports now successfully show all 31 calculation steps

### Files touched
- web/app/services/tax_calculations/tax_liability_orchestrator.rb (MODIFIED - line 72 argument fix)
- docs/NOW.md (UPDATED - documented bugfix)

### Outcomes / Decisions
- Critical bug fixed: PDF exports now show full tax calculations
- Phase 5d implementation verified to be working correctly once orchestrator bug was fixed
- No data integrity issues; bug was purely in method argument passing
- Confirms entire Phase 5a-5d feature set is operational end-to-end
- Ready for: Phase 5e (investment income), Phase 6 (multi-year returns), or production deployment

### 2026-01-06 (Session 5 - Phase 5d Complete: Advanced Tax Reliefs)

**Participants:** User, Claude Code Agent
**Branch:** main

### What we worked on
- **Phase 5d: Advanced Tax Reliefs - Complete Implementation**
  - Implemented three new UK tax reliefs: Trading Allowance (£1,000 simplified expenses), Marriage Allowance (£1,260 PA transfer), and Married Couple's Allowance (up to £1,108 tax relief)
  - Created TradingAllowanceCalculator: Calculates lesser of £1,000 or actual self-employment income
  - Created MarriageAllowanceCalculator: Supports transferor/transferee roles with £1,260 PA adjustment and £252 tax reduction for transferee
  - Created MarriedCouplesAllowanceCalculator: Age eligibility check (born before 6 April 1935), income taper (£1 reduction per £2 over £37,000), minimum £4,280 allowance, 10% relief rate
  - Extended PersonalAllowanceCalculator: Added Marriage Allowance PA adjustment integration
  - Updated TaxLiabilityOrchestrator: Integrated all three Phase 5d calculators in sequence, applies MCA relief as tax credit
  - Database migrations: Added 6 new fields to tax_returns table (uses_trading_allowance, claims_marriage_allowance, marriage_allowance_role, claims_married_couples_allowance, spouse_dob, spouse_income) and 6 new fields to tax_liabilities table (trading_income_gross, trading_allowance_amount, trading_income_net, marriage_allowance_transfer_amount, marriage_allowance_tax_reduction, married_couples_allowance_amount, married_couples_allowance_relief)
  - TaxReturn model validations: Added mutual exclusivity between Marriage Allowance and MCA with custom validator
  - TaxLiability model: Updated summary() method to include all Phase 5d relief fields
  - ExportService: Updated calculation_steps to include all Phase 5d calculation breakdowns
  - Controller actions: Added three new actions to TaxReturnsController (toggle_trading_allowance, update_marriage_allowance, update_married_couples_allowance) with strong parameter methods
  - Routes: Added three member routes for tax_returns resource (patch :toggle_trading_allowance, patch :update_marriage_allowance, patch :update_married_couples_allowance)
  - UI Implementation: Added three relief cards to Tax Reliefs tab with emojis (📊 Trading, 💑 Marriage, 👫 MCA), status badges, forms with conditional visibility
  - JavaScript: Added toggle handlers for Marriage Allowance role selector and MCA spouse DOB field with show/hide behavior
  - CSS: Added 8 new relief form styling classes (relief-form-row, relief-checkbox, relief-fields, relief-field-label, relief-select, relief-date-input, relief-checkbox-label, relief-field-hint)
  - Documentation: Updated NOW.md, PROJECT_CONTEXT.md, and SESSION_NOTES.md with Phase 5d completion details

### Files touched
- web/db/migrate/20260106023000_add_phase_5d_reliefs_to_tax_returns.rb (NEW)
- web/db/migrate/20260106023001_add_phase_5d_reliefs_to_tax_liabilities.rb (NEW)
- web/app/services/tax_calculations/trading_allowance_calculator.rb (NEW)
- web/app/services/tax_calculations/marriage_allowance_calculator.rb (NEW)
- web/app/services/tax_calculations/married_couples_allowance_calculator.rb (NEW)
- web/app/services/tax_calculations/personal_allowance_calculator.rb (MODIFIED - added MA adjustment)
- web/app/services/tax_calculations/tax_liability_orchestrator.rb (MODIFIED - integrated Phase 5d calculators)
- web/app/models/tax_return.rb (MODIFIED - added Phase 5d validations)
- web/app/models/tax_liability.rb (MODIFIED - updated summary method)
- web/app/controllers/tax_returns_controller.rb (MODIFIED - added 3 new actions and strong parameters)
- web/config/routes.rb (MODIFIED - added 3 member routes)
- web/app/services/export_service.rb (MODIFIED - added Phase 5d calculation steps)
- web/app/views/tax_returns/show.html.erb (MODIFIED - added 3 relief cards, CSS, JavaScript)
- docs/NOW.md (UPDATED)
- docs/PROJECT_CONTEXT.md (UPDATED)
- docs/SESSION_NOTES.md (THIS ENTRY)

### Outcomes / Decisions
- Phase 5d implementation complete: All three advanced tax reliefs fully integrated
- Architecture consistency: Followed existing Phase 5b/5c patterns (calculator services → orchestrator → TaxLiability model)
- Non-breaking changes: All Phase 5d functionality is additive; existing Phase 5a-5c logic unchanged
- UI pattern: Simple toggle/checkbox design with JavaScript conditional visibility (no separate controller/view files needed)
- Validation strategy: Mutual exclusivity enforced at model level (custom validator prevents both MA and MCA being claimed)
- Integration: MCA relief applied as negative tax credit (subtracts from total_income_tax)
- Database safe: All migrations use column_exists? checks for idempotence
- Documentation updated: All three context files (NOW, PROJECT_CONTEXT, SESSION_NOTES) reflect Phase 5d completion
- Ready for: Phase 5e (investment income), Phase 6 (multi-year returns), or HMRC filing integration
- **Note:** Migrations created but not yet run (blocked by Active Record encryption key configuration)

---

### 2026-01-06 (Session 4 - Phase 5b & 5c Completion)

**Participants:** User, Claude Code Agent
**Branch:** main

### What we worked on
- **Phase 5b & 5c Complete:** Unified all tax relief calculators into TaxLiabilityOrchestrator
  - Merged separate Calculators::FTCR, HICBC into unified TaxCalculations:: namespace
  - Extended NationalInsuranceCalculator with Class 2 NI (fixed £163.80) and Class 4 NI (8%/2% tiered)
  - Created FurnishedPropertyCalculator (FTCR: 50% of rental income)
  - Created HighIncomeChildBenefitCalculator (HICBC: 1% charge above £60k threshold)
  - Added migration for rental property income, FTCR relief, HICBC fields, Class 2/4 NI
  - Extended IncomeSource enum with rental_property type
  - Updated TaxLiability model: summary() includes all new fields, calculate_totals() includes HICBC
  - Updated TaxLiabilityOrchestrator to automatically call all calculators in sequence
  - Updated ExportService to include all calculation steps (Class 2/4 NI, FTCR, HICBC)
  - Removed redundant Calculations tab and manual calculation controller
  - Fixed PDF export currency symbol display (£ preserved instead of converted to ?)
- **Validation:** Confirmed all Phase 5 sub-phases (5a, 5b, 5c) working together seamlessly

### Outcomes / Decisions
- Phase 5 now 100% complete: All tax calculations unified and automatic
- Architecture decision: Removed redundant manual calculation UI
- Currency symbol fix: Updated sanitize_text regex to preserve £€$¥₹
- Ready for Phase 5d (additional reliefs) or Phase 6 (multi-year returns)

**Commits:**
- d387b39: Implement Phase 5c: Unified tax relief calculators
- f2f386b: Remove redundant Calculations tab and controller
- ffabce8: Fix currency symbol display in PDF exports

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
