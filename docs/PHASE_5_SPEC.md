# Phase 5 Specification: Full Tax Calculation Engine
## UK Self Assessment Income Tax & NICs Calculator

**Status:** Phase Planning (not yet in development)
**Tax Year:** 2024-25 (6 April 2024 to 5 April 2025)
**Canonical Reference:** HMRC SA100, SA102, SA103 forms
**Priority:** Phase 5+ (backlog, not critical for MVP)

---

## Executive Summary

Phase 5 implements a **full UK tax calculation engine** that automatically computes income tax, National Insurance, and related liabilities from user-entered income sources. This addresses the gap where Phase 4 only included deterministic relief calculators (FTCR, HICBC, Gift Aid) but no income→tax liability engine.

The engine will:
1. **Aggregate income** from multiple sources (employment, self-employment, pensions, dividends, interest)
2. **Calculate taxable income** after reliefs and allowances
3. **Compute tax liability** using 2024-25 tax bands and thresholds
4. **Calculate National Insurance** (Class 1, Class 4)
5. **Auto-prefill SA100/SA102** form boxes with calculated values
6. **Track calculation steps** for transparency and audit

---

## 1. Phase Decomposition

### Phase 5a: Basic Income + Tax Calculation
**Scope:** Single employment income → basic tax liability
**Effort:** Medium (foundation phase)
**Deliverables:**
- Employment income aggregation (multiple employments)
- Personal Allowance calculation
- Basic Rate tax band (20%)
- Basic National Insurance (Class 1)
- Form prefill for SA102 basic fields

### Phase 5b: Pension & Relief Integration
**Scope:** Extend with pension contributions, Gift Aid, Blind Allowance
**Effort:** Medium
**Deliverables:**
- Pension contribution relief (basic rate / relief at source)
- Gift Aid tax relief (20% uplift)
- Blind Person's Allowance
- Charitable giving relief
- Recalculate tax after reliefs

### Phase 5c: Investment Income
**Scope:** Dividends, interest, capital gains
**Effort:** High
**Deliverables:**
- Dividend income aggregation
- Savings interest (NSI, bank, building society)
- Dividend Allowance (£500 for 2024-25)
- Savings Allowance (£1,000 basic, £500 higher rate)
- Capital Gains Tax calculation
- Higher rate (40%) and additional rate (45%) bands

### Phase 5d: Self-Employment & Partnerships
**Scope:** Self-employment profits, partnership allocations
**Effort:** High
**Deliverables:**
- Self-employment net profit calculation
- Class 2 and Class 4 National Insurance
- Trading Allowance (if applicable)
- Partnership profit allocation
- Capital Allowances

### Phase 5e: Advanced Reliefs & Edge Cases
**Scope:** Marriage Allowance, Married Couple's Allowance, non-resident, trusts
**Effort:** High (lowest priority)
**Deliverables:**
- Marriage Allowance transfer
- Married Couple's Allowance (MCA)
- Residence basis and foreign tax credits
- Trust income aggregation
- Seafarer's Earnings Deduction

---

## 2. Data Model Changes

### New Models Required

#### `TaxBand` (Configuration Model)
Stores 2024-25 tax thresholds and rates.
```ruby
class TaxBand
  # Income ranges for each band
  0–12,570        # Personal Allowance (PA)
  12,571–50,270   # Basic Rate (20%)
  50,271–125,140  # Higher Rate (40%)
  125,141+        # Additional Rate (45%)

  # National Insurance thresholds
  0–12,570        # Exempt
  12,571–50,270   # Class 1 (8%)
  50,271+         # Class 1 (2%)
end
```

#### `IncomeSource` (Model)
Aggregates all income for a tax return.
```ruby
class IncomeSource < ApplicationRecord
  belongs_to :tax_return

  enum source_type: {
    employment: 0,
    self_employment: 1,
    dividends: 2,
    interest: 3,
    pension: 4,
    other: 5
  }

  # Gross amount before tax/deductions
  amount_gross: integer
  # Amount already taxed at source (PAYE, etc.)
  amount_tax_taken: integer
  # Description (employer name, business, etc.)
  description: string
  # Tax treatment flags
  is_eligible_for_pa: boolean  # Counts toward Personal Allowance
  is_eligible_for_relief: boolean  # Qualifies for relief
end
```

#### `TaxCalculationBreakdown` (Model)
Stores intermediate calculation steps for transparency.
```ruby
class TaxCalculationBreakdown < ApplicationRecord
  belongs_to :tax_calculation

  # Calculation step reference (e.g., "employment_aggregation", "pa_relief", "basic_rate_tax")
  step_key: string
  # Input values for this step
  inputs: jsonb  # {employment_1: 50000, employment_2: 25000}
  # Intermediate result
  result: decimal
  # Calculation formula/explanation for audit
  explanation: text
end
```

#### `TaxLiability` (Model)
Final calculated tax liability for the return.
```ruby
class TaxLiability < ApplicationRecord
  belongs_to :tax_return

  # Total gross income
  total_gross_income: decimal

  # After reliefs/allowances
  taxable_income: decimal

  # Tax calculations by band
  basic_rate_tax: decimal        # 20%
  higher_rate_tax: decimal       # 40%
  additional_rate_tax: decimal   # 45%
  total_income_tax: decimal

  # National Insurance
  class_1_ni: decimal
  class_2_ni: decimal
  class_4_ni: decimal
  total_ni: decimal

  # Total liability
  total_tax_and_ni: decimal

  # Tax paid at source (for comparison)
  tax_paid_at_source: decimal

  # Net payable/repayable
  net_liability: decimal  # positive = owed, negative = repayment

  # Calculation metadata
  calculation_inputs: jsonb  # References to TaxCalculationBreakdowns
  calculated_at: datetime
  calculated_by: string  # "user_input" | "auto_extraction" | "rollforward"
end
```

---

## 3. Calculation Logic: Phase 5a (Basic Income)

### 3.1 Employment Income Aggregation

**Input:** Multiple EmploymentIncomeSource records from SA102 forms

**Calculation Steps:**

```
1. Aggregate pay from all employments
   total_employment_pay = SUM(SA102.box1 for all employments)

2. Add other employment-related income
   + tips and other payments (SA102.box3)
   + pension contributions from HMRC (SA102.box3.1)
   total_gross_employment = total_employment_pay + tips + pension_payment

3. Deduct employment expenses (if applicable)
   - business travel/subsistence (SA102.box17)
   - fixed deductions (SA102.box18)
   - professional fees (SA102.box19)
   - other capital allowances (SA102.box20)
   net_employment_income = total_gross_employment - expenses

4. Calculate taxable employment income
   (Note: Benefits and balancing charges added separately in Phase 5c)
```

**Output:** `EmploymentAggregation` object with:
- `total_gross_pay`: £ (from P60)
- `total_benefits`: £ (P11D items, added in Phase 5c)
- `total_expenses`: £
- `net_employment_income`: £

### 3.2 Personal Allowance Relief

**Input:** Employment aggregation, age (DOB), residency status

**Calculation:**

```
personal_allowance = 12,570  # Standard for 2024-25 under age 65

# Higher allowance for age 65+
if age >= 65 and age < 75:
  personal_allowance = 12,570  # No higher amount in 2024-25 (frozen)
elif age >= 75:
  personal_allowance = 12,570  # Frozen

# Income limits for higher allowances (2024-25)
# If income > £125,140, PA is nil
if total_income > 125_140:
  personal_allowance = 0
```

**Output:** `PersonalAllowanceCalculation` with:
- `gross_income`: £
- `pa_amount`: £
- `unused_pa`: £ (for Marriage Allowance eligibility)

### 3.3 Taxable Income

**Input:** Net employment income, Personal Allowance, other income (Phase 5b+)

**Calculation:**

```
taxable_income = MAX(0, net_employment_income - personal_allowance)

# Note: This is simplified for Phase 5a
# Phase 5b adds pension relief, Gift Aid, etc.
```

**Output:** Taxable income figure for band calculation

### 3.4 Tax Liability by Band

**Input:** Taxable income, tax band thresholds

**Calculation:**

```
# 2024-25 Tax bands
basic_rate_limit = 50,270
higher_rate_limit = 125,140

if taxable_income <= 50_270:
  basic_rate_tax = taxable_income * 0.20
  higher_rate_tax = 0
  additional_rate_tax = 0

elsif taxable_income <= 125_140:
  basic_rate_tax = 50_270 * 0.20  # £10,054
  higher_rate_tax = (taxable_income - 50_270) * 0.40
  additional_rate_tax = 0

else:
  basic_rate_tax = 50_270 * 0.20  # £10,054
  higher_rate_tax = (125_140 - 50_270) * 0.40  # £29,948
  additional_rate_tax = (taxable_income - 125_140) * 0.45

total_income_tax = basic_rate_tax + higher_rate_tax + additional_rate_tax
```

**Output:** Tax liability by band

### 3.5 National Insurance Class 1 (Employees)

**Input:** Employment income, thresholds

**Calculation:**

```
# 2024-25 NI thresholds
ni_lower_threshold = 12_570
ni_upper_threshold = 50_270

taxable_ni_income = employment_income - ni_lower_threshold

if taxable_ni_income <= 0:
  class_1_ni = 0
elsif taxable_ni_income <= (ni_upper_threshold - ni_lower_threshold):
  # 8% on earnings between £12,571 and £50,270
  class_1_ni = taxable_ni_income * 0.08
else:
  # 8% on £12,571–£50,270
  basic_ni = (ni_upper_threshold - ni_lower_threshold) * 0.08  # £2,995.60
  # 2% on earnings above £50,270
  excess_ni = (taxable_ni_income - (ni_upper_threshold - ni_lower_threshold)) * 0.02
  class_1_ni = basic_ni + excess_ni
```

**Output:** Class 1 National Insurance payable

### 3.6 Tax Paid at Source Reconciliation

**Input:** SA102.box2 (tax already taken off PAYE), calculated tax liability

**Calculation:**

```
total_tax_and_ni = total_income_tax + class_1_ni
tax_paid_at_source = SA102.box2  # From P60

net_liability = total_tax_and_ni - tax_paid_at_source
# Positive = amount owed, Negative = repayment due
```

**Output:** Net liability or repayment

---

## 4. Form Prefill Strategy

### 4.1 SA100 Auto-Fill (Basic Phase 5a)

The engine will populate these SA100 boxes with calculated values:

| Box | Description | Calculation Source | Approval Required? |
|-----|-------------|--------------------|--------------------|
| 1.1 | Date of birth | User profile | Pre-filled |
| TR3 Box 1-7 | Income sections | SUM of IncomeSource records | Auto (calculated) |
| TR4 Box 1-16 | Tax reliefs (if applicable) | TaxLiability breakdown | Auto (calculated) |
| TR5 | Student Loan/NI/HICBC | Separate calculations | Auto (Phase 5b+) |
| TR6 | Tax refund/repayment | TaxLiability.net_liability | Auto (calculated) |

### 4.2 SA102 Auto-Fill (Basic Phase 5a)

For each employment:

| Box | Description | Calculation Source | Approval Required? |
|-----|-------------|--------------------|--------------------|
| 1 | Total pay from employment | P60 (user-entered) | User enters |
| 2 | Tax taken off | P60 (user-entered) | User enters |
| 5-8 | Employer details | User enters | User enters |
| 9-20 | Benefits and expenses | P11D (user-entered) or auto | User confirmation |

### 4.3 Approval Flow

**User Journey:**
1. User enters or uploads income sources (P60, P11D, etc.)
2. System auto-calculates tax liability
3. User reviews calculated values in "Tax Calculation Summary" page
4. User approves or modifies calculations
5. Approved values are locked and prefilled in export
6. Export generates SA100/SA102 with calculated values shown

**Key:** Auto-calculations should be **suggestions** that users can override, not locked values.

---

## 5. Architecture: Calculation Services

### 5.1 Calculation Service Classes

Create modular services under `app/services/tax_calculations/`:

```
app/services/
  ├─ tax_calculations/
  │  ├─ income_aggregator.rb          # Phase 5a
  │  ├─ personal_allowance_calculator.rb
  │  ├─ tax_band_calculator.rb
  │  ├─ national_insurance_calculator.rb  # Phase 5a
  │  ├─ pension_relief_calculator.rb   # Phase 5b
  │  ├─ gift_aid_calculator.rb         # Phase 5b (exists)
  │  ├─ investment_income_calculator.rb # Phase 5c
  │  ├─ self_employment_calculator.rb  # Phase 5d
  │  ├─ marriage_allowance_calculator.rb # Phase 5e
  │  └─ tax_liability_orchestrator.rb  # Master orchestrator
  └─ export_service.rb                 # Updated for Phase 5
```

### 5.2 Service Design Pattern

Each calculator service follows this pattern:

```ruby
module TaxCalculations
  class PersonalAllowanceCalculator
    def initialize(tax_return)
      @tax_return = tax_return
      @user = tax_return.user
    end

    def calculate
      pa = base_allowance
      pa = apply_age_relief(pa) if eligible_for_higher?
      pa = apply_income_withdrawal(pa) if high_income?

      TaxCalculationBreakdown.create!(
        tax_return: @tax_return,
        step_key: 'personal_allowance',
        inputs: {dob: @user.dob, gross_income: total_income},
        result: pa,
        explanation: "Standard PA of £12,570"
      )

      pa
    end

    private
    def base_allowance
      12_570  # 2024-25
    end
    # ... other methods
  end
end
```

### 5.3 Master Orchestrator

`TaxLiabilityOrchestrator` runs all calculators in sequence:

```ruby
module TaxCalculations
  class TaxLiabilityOrchestrator
    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Phase 5a: Basic income + tax
      employment_income = IncomeAggregator.new(@tax_return).calculate
      personal_allowance = PersonalAllowanceCalculator.new(@tax_return).calculate
      taxable_income = [employment_income - personal_allowance, 0].max

      income_tax = TaxBandCalculator.new(taxable_income).calculate
      class_1_ni = NationalInsuranceCalculator.new(employment_income).calculate

      # Phase 5b: Reliefs
      pension_relief = PensionReliefCalculator.new(@tax_return).calculate
      gift_aid_relief = GiftAidCalculator.new(@tax_return).calculate

      # Recalculate tax after reliefs (if enabled)
      # ... Phase 5b logic

      # Create TaxLiability record
      TaxLiability.create!(
        tax_return: @tax_return,
        total_gross_income: employment_income,
        taxable_income: taxable_income,
        basic_rate_tax: ...,
        higher_rate_tax: ...,
        total_income_tax: income_tax,
        class_1_ni: class_1_ni,
        total_tax_and_ni: income_tax + class_1_ni,
        calculation_inputs: {employment: employment_income, ...}
      )
    end
  end
end
```

---

## 6. Database Migrations

### 6.1 New Tables

```ruby
# Phase 5a minimum
create_table :income_sources do |t|
  t.references :tax_return, foreign_key: true
  t.integer :source_type  # enum: employment, self_employment, dividends, etc.
  t.decimal :amount_gross
  t.decimal :amount_tax_taken
  t.string :description
  t.boolean :is_eligible_for_pa, default: true
  t.boolean :is_eligible_for_relief, default: false
  t.timestamps
end

create_table :tax_liabilities do |t|
  t.references :tax_return, foreign_key: true
  t.decimal :total_gross_income
  t.decimal :taxable_income
  t.decimal :basic_rate_tax
  t.decimal :higher_rate_tax
  t.decimal :additional_rate_tax
  t.decimal :total_income_tax
  t.decimal :class_1_ni
  t.decimal :class_2_ni
  t.decimal :class_4_ni
  t.decimal :total_ni
  t.decimal :total_tax_and_ni
  t.decimal :tax_paid_at_source
  t.decimal :net_liability
  t.jsonb :calculation_inputs
  t.string :calculated_by  # "auto" | "user_override"
  t.timestamps
end

create_table :tax_calculation_breakdowns do |t|
  t.references :tax_return, foreign_key: true
  t.string :step_key  # "employment_aggregation", "pa_relief", etc.
  t.jsonb :inputs
  t.decimal :result
  t.text :explanation
  t.integer :sequence_order  # For audit trail ordering
  t.timestamps
end

create_table :tax_bands do |t|
  t.integer :tax_year  # 2024, 2025, etc.
  t.decimal :pa_amount
  t.decimal :basic_rate_limit
  t.decimal :higher_rate_limit
  t.decimal :basic_rate_percentage
  t.decimal :higher_rate_percentage
  t.decimal :additional_rate_percentage
  t.decimal :ni_lower_threshold
  t.decimal :ni_upper_threshold
  t.decimal :ni_basic_percentage
  t.decimal :ni_higher_percentage
  t.timestamps
end
```

### 6.2 Model Updates

```ruby
# TaxReturn model (add associations)
has_many :income_sources, dependent: :destroy
has_one :tax_liability, dependent: :destroy
has_many :tax_calculation_breakdowns, dependent: :destroy

# User model (add DOB if not present)
validates :date_of_birth, presence: true
```

---

## 7. UI/UX Changes

### 7.1 New Pages

**1. Income Entry Page** (`/tax_returns/:id/income_sources`)
- Form to enter/upload employment, dividend, interest income
- Support P60, P11D file upload with OCR extraction (Phase 5b+)
- Calculate net income with expenses
- Preview aggregated total

**2. Tax Calculation Summary** (`/tax_returns/:id/tax_calculation`)
- Display calculation breakdown (all steps)
- Show intermediate values for transparency
- Allow user to override automatic values
- "Approve calculation" button to lock values for export

**3. SA100/SA102 Preview** (updated)
- Show calculated values pre-filled in form preview
- Show calculation references for each box
- Allow edit-in-place for manual adjustments
- Lock calculated values until user explicitly edits

### 7.2 Export Updates

Update `PDFExportService` to include:
- New section: "Tax Calculation Summary"
- Calculation breakdown with references
- Final tax liability figures
- SA100/SA102 boxes with calculated values highlighted

---

## 8. Acceptance Criteria

### Phase 5a (Basic Income): MVP
- [ ] Employment income aggregation from multiple P60s
- [ ] Personal Allowance calculated correctly (£12,570)
- [ ] Tax liability calculated by band (20%, 40%, 45%)
- [ ] Class 1 National Insurance calculated (8%, 2%)
- [ ] Tax paid at source reconciliation (net liability)
- [ ] SA102 boxes auto-prefilled with calculated values
- [ ] Calculation breakdown viewable and editable by user
- [ ] Export includes calculation summary with tax liability
- [ ] Unit tests for all calculators (>90% coverage)
- [ ] Integration test: P60 → SA102 prefill → export PDF

### Phase 5b: Reliefs
- [ ] Pension contribution relief calculated
- [ ] Gift Aid relief calculated (20% uplift)
- [ ] Blind Person's Allowance applied
- [ ] Tax recalculated after reliefs
- [ ] Marriage Allowance logic (defer to Phase 5e)
- [ ] All relief test cases pass

### Phase 5c: Investment Income
- [ ] Dividend income aggregation
- [ ] Dividend Allowance applied (£500)
- [ ] Savings interest aggregation
- [ ] Savings Allowance applied
- [ ] Capital Gains Tax calculation
- [ ] Higher rate and additional rate bands applied correctly

### Phase 5d: Self-Employment
- [ ] Self-employment net profit calculation
- [ ] Class 2 National Insurance (fixed £163.80)
- [ ] Class 4 National Insurance (9% up to £50,270, 2% above)
- [ ] Trading Allowance applied if eligible
- [ ] Partnership profit allocation

### Phase 5e: Advanced Reliefs
- [ ] Marriage Allowance transfer logic
- [ ] Married Couple's Allowance (if applicable by age)
- [ ] Non-resident and foreign tax relief
- [ ] Trust income aggregation

---

## 9. Implementation Roadmap

### Sprint 1: Phase 5a Foundation
**Week 1-2:**
- Create TaxBand, IncomeSource, TaxLiability, TaxCalculationBreakdown models
- Implement IncomeAggregator service
- Implement PersonalAllowanceCalculator
- Write unit tests

**Week 3-4:**
- Implement TaxBandCalculator
- Implement NationalInsuranceCalculator
- Implement TaxLiabilityOrchestrator
- Integration testing

**Week 5:**
- Build Income Entry UI page
- Build Tax Calculation Summary page
- User override/edit flow
- Export integration

### Sprint 2: Phase 5b (Reliefs)
**Week 1-2:**
- Implement PensionReliefCalculator
- Extend GiftAidCalculator integration
- Implement BlindPersonAllowanceCalculator
- Recalculation logic after reliefs

**Week 3:**
- UI for relief entry/selection
- Update export with relief summaries
- Testing

### Sprints 3+: Phases 5c, 5d, 5e
(Detailed planning deferred until Phase 5a is complete)

---

## 10. Known Constraints & Assumptions

### Constraints
- **Tax year:** 2024-25 only initially (make configurable for future)
- **Simplifications for MVP:**
  - No married couple's allowance (Phase 5e)
  - No non-resident/foreign tax logic (Phase 5e)
  - No partnership adjustments (Phase 5d)
  - No capital allowances detailed calculation (Phase 5d)

### Assumptions
- **User enters accurate P60/P11D data** (no HMRC API verification)
- **Tax bands and thresholds are fixed** (2024-25 values hardcoded initially, make configurable in Phase 5b+)
- **No NI contributions tracking** (assumes PAYE deductions correct)
- **Personal Allowance never nil** for Phase 5a (defer high-income withdrawal logic to Phase 5b)

### Future Enhancements (Post-Phase 5)
- HMRC API integration for actual P60/P11D retrieval
- OCR/PDF parsing for automatic income source extraction
- Scenario modeling ("what if" calculator)
- Tax planning recommendations
- Real-time filing integration with HMRC online

---

## 11. Testing Strategy

### Unit Tests
Each calculator has isolated tests:
```ruby
describe TaxCalculations::PersonalAllowanceCalculator do
  it "returns £12,570 for standard rate" do
    # Standard person under 65
    tax_return = create(:tax_return, dob: 30.years.ago)
    calc = PersonalAllowanceCalculator.new(tax_return)
    expect(calc.calculate).to eq(12_570)
  end

  it "applies income withdrawal above £125,140" do
    # High earner
    tax_return = create(:tax_return)
    allow_any_instance_of(TaxCalculations::IncomeAggregator)
      .to receive(:calculate).and_return(150_000)
    calc = PersonalAllowanceCalculator.new(tax_return)
    expect(calc.calculate).to eq(0)
  end
end
```

### Integration Tests
End-to-end scenarios:
```ruby
describe "Basic employment income tax calculation" do
  it "calculates correct tax and NI for single employment" do
    tax_return = create(:tax_return)
    IncomeSource.create!(
      tax_return: tax_return,
      source_type: :employment,
      amount_gross: 50_000,
      amount_tax_taken: 7_000
    )

    liability = TaxCalculations::TaxLiabilityOrchestrator.new(tax_return).calculate

    expect(liability.total_income_tax).to eq(7_486)  # (50k - 12.57k) * 0.20
    expect(liability.class_1_ni).to eq(2_995.60)     # (50k - 12.57k) * 0.08
    expect(liability.net_liability).to eq(2_481.60)  # Total - tax already taken
  end
end
```

### Validation Tests
Known-good calculations:
- HMRC Sample 1: £40k employment → £5,486 tax, £2,195 NI
- HMRC Sample 2: £60k employment → £9,486 tax, £3,795 NI
- HMRC Sample 3: £100k + £10k dividend → £17,746 tax, £4,795 NI

---

## 12. Success Metrics

### Functional
- ✅ All SA100/SA102 boxes correctly calculated for given inputs
- ✅ Tax liability matches HMRC calculators for 50+ test cases
- ✅ Calculation breakdown transparent and editable by user
- ✅ Export includes full calculation audit trail

### Quality
- ✅ >90% unit test coverage for all calculators
- ✅ Zero critical bugs in first 3 months (post-release)
- ✅ All HMRC edge cases handled (income limits, withdrawals, etc.)

### User Experience
- ✅ Calculation takes <2 seconds (< 1 page load)
- ✅ User can understand and override any calculated value
- ✅ Export PDF is valid and readable

---

## 13. Appendix: 2024-25 Tax Thresholds

**Personal Allowance:** £12,570
**Basic Rate Band:** £12,571–£50,270 @ 20%
**Higher Rate Band:** £50,271–£125,140 @ 40%
**Additional Rate:** £125,141+ @ 45%

**National Insurance Class 1 (Employees):**
- Lower threshold: £12,570
- Upper threshold: £50,270
- Basic rate: 8% (£12,571–£50,270)
- Higher rate: 2% (£50,271+)

**Dividend Allowance:** £500
**Savings Allowance (Basic):** £1,000
**Savings Allowance (Higher):** £500

**Marriage Allowance:** £1,260 transferable allowance (income < £12,570)

**Blind Person's Allowance:** £2,820 additional allowance

**Student Loan Repayment:**
- Plan 1: 9% of earnings above £20,195
- Plan 2: 9% of earnings above £27,725

**High Income Child Benefit Charge:** 1% for every £200 over £60,000 (max 100% of benefit)

---

## 14. References

- HMRC SA100 Tax Return 2025 (Blank Form): `docs/references/Blank Tax Return (2025) - SA100-2025.pdf`
- HMRC SA102 Employment 2025 (Blank Form): `docs/references/Blank Employment (2025) - SA102_2025.pdf`
- HMRC Tax & NI Rates 2024-25: https://www.gov.uk/government/publications/rates-and-allowances-2024-to-2025
- Project Spec: `docs/spec.md`
- Current Build: `docs/SPEC_DRIFT_ANALYSIS.md`

---

**Document Version:** 1.0
**Last Updated:** 2026-01-05
**Author:** Claude Code Agent
**Status:** Ready for Review & User Approval
