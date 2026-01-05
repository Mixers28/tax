# Phase 5a Implementation: Basic Employment Income Tax Calculator

## Overview

Phase 5a implements the foundation of the UK tax calculation engine, focusing on:
- Employment income aggregation from multiple P60s
- Personal Allowance calculation (£12,570 with withdrawal above £125,140)
- Tax liability calculation by band (20%, 40%, 45%)
- Class 1 National Insurance calculation (8%, 2%)
- Full calculation breakdown for transparency and audit

## Architecture

### Models

**TaxBand** (`app/models/tax_band.rb`)
- Stores 2024-25 tax thresholds and rates
- Auto-creates defaults for current tax year
- Thresholds: PA £12,570, Basic to £50,270, Higher to £125,140, Additional 45%+

**IncomeSource** (`app/models/income_source.rb`)
- Represents individual income sources (employment, self-employment, etc.)
- Tracks gross amount, tax paid at source, eligibility flags
- Enums: employment, self_employment, dividends, interest, pension, other

**TaxLiability** (`app/models/tax_liability.rb`)
- Stores calculated tax liability for a tax return
- Includes breakdown: tax by band, NI by class, net liability
- One-to-one with TaxReturn
- Helpers: `owes_tax?`, `refund_due?`, `summary`

**TaxCalculationBreakdown** (`app/models/tax_calculation_breakdown.rb`)
- Records each calculation step for transparency
- Stores inputs, result, and explanation for each step
- Enables full audit trail of how final number was calculated

### Services

All services located in `app/services/tax_calculations/`

**IncomeAggregator**
- Sums employment and self-employment income
- Returns total gross income
- Records step in TaxCalculationBreakdown

**PersonalAllowanceCalculator**
- Calculates £12,570 base allowance
- Applies withdrawal above £125,140 (£1 withdrawn per £2 over threshold)
- Returns net PA after withdrawal

**TaxBandCalculator**
- Applies 2024-25 tax bands to taxable income
- Returns breakdown: basic, higher, additional tax amounts
- Handles all income levels correctly

**NationalInsuranceCalculator**
- Calculates Class 1 NI (employees)
- 8% on £12,571-£50,270
- 2% on £50,271+
- (Phase 5d will add Class 2 & 4 for self-employed)

**TaxLiabilityOrchestrator**
- Master calculator that orchestrates all sub-calculators
- Calls IncomeAggregator → PersonalAllowanceCalculator → TaxBandCalculator → NationalInsuranceCalculator
- Creates/updates TaxLiability record
- Records final summary step

## Database

### New Tables

```ruby
CREATE TABLE tax_bands (
  tax_year INTEGER UNIQUE NOT NULL,
  pa_amount DECIMAL(12,2),
  basic_rate_limit DECIMAL(12,2),
  higher_rate_limit DECIMAL(12,2),
  basic_rate_percentage DECIMAL(5,2),
  higher_rate_percentage DECIMAL(5,2),
  additional_rate_percentage DECIMAL(5,2),
  ni_lower_threshold DECIMAL(12,2),
  ni_upper_threshold DECIMAL(12,2),
  ni_basic_percentage DECIMAL(5,2),
  ni_higher_percentage DECIMAL(5,2)
);

CREATE TABLE income_sources (
  tax_return_id INTEGER FOREIGN KEY,
  source_type INTEGER (enum: 0=employment, 1=self_employment, ...),
  amount_gross DECIMAL(12,2),
  amount_tax_taken DECIMAL(12,2),
  description VARCHAR,
  is_eligible_for_pa BOOLEAN,
  is_eligible_for_relief BOOLEAN
);

CREATE TABLE tax_liabilities (
  tax_return_id INTEGER UNIQUE FOREIGN KEY,
  total_gross_income DECIMAL(12,2),
  taxable_income DECIMAL(12,2),
  basic_rate_tax DECIMAL(12,2),
  higher_rate_tax DECIMAL(12,2),
  additional_rate_tax DECIMAL(12,2),
  total_income_tax DECIMAL(12,2),
  class_1_ni DECIMAL(12,2),
  tax_paid_at_source DECIMAL(12,2),
  net_liability DECIMAL(12,2) -- positive = owed, negative = refund
);

CREATE TABLE tax_calculation_breakdowns (
  tax_return_id INTEGER FOREIGN KEY,
  step_key VARCHAR,
  inputs JSONB,
  result DECIMAL(12,2),
  explanation TEXT,
  sequence_order INTEGER
);
```

### Migrations

Run migrations to create tables:
```bash
cd web
rails db:migrate
```

Migrations:
- `db/migrate/20260105100700_create_tax_bands.rb`
- `db/migrate/20260105100800_create_income_sources.rb`
- `db/migrate/20260105100900_create_tax_calculation_breakdowns.rb`
- `db/migrate/20260105101000_create_tax_liabilities.rb`

## Usage

### Basic Calculation

```ruby
# Create income sources for a tax return
tax_return = TaxReturn.first

# Add employment income(s)
IncomeSource.create!(
  tax_return: tax_return,
  source_type: :employment,
  amount_gross: 50_000,
  amount_tax_taken: 7_500,
  description: "Employment at ACME Corp"
)

# Run the full calculation
liability = TaxCalculations::TaxLiabilityOrchestrator.new(tax_return).calculate

# Access results
puts "Gross Income: £#{liability.total_gross_income}"
puts "Taxable Income: £#{liability.taxable_income}"
puts "Income Tax: £#{liability.total_income_tax}"
puts "National Insurance: £#{liability.class_1_ni}"
puts "Total Liability: £#{liability.total_tax_and_ni}"
puts "Tax Paid: £#{liability.tax_paid_at_source}"
puts "Net Payable/(Refund): £#{liability.net_liability}"

# Check calculation steps
TaxCalculationBreakdown.for_return(tax_return).each do |breakdown|
  puts "#{breakdown.step_key}: #{breakdown.explanation}"
end
```

### Query TaxLiability

```ruby
# Get liability for a return
liability = tax_return.tax_liability

# Check if user owes or gets refund
if liability.owes_tax?
  puts "Amount owed: £#{liability.net_liability}"
elsif liability.refund_due?
  puts "Refund due: £#{liability.net_liability.abs}"
end

# Get summary
summary = liability.summary
# => { total_gross_income, taxable_income, total_income_tax, ... }
```

## Test Scenarios (2024-25)

Test files in `spec/services/tax_calculations/`:
- `personal_allowance_calculator_spec.rb` - PA calculations
- `tax_band_calculator_spec.rb` - Tax by band
- `national_insurance_calculator_spec.rb` - Class 1 NI
- `tax_liability_orchestrator_spec.rb` - Integration tests

### Example 1: £50,000 Employment Income
- Gross: £50,000
- PA: £12,570
- Taxable: £37,430
- Tax: £7,486
- NI: £2,994
- Total: £10,480
- (Assuming £7,500 paid at source → Owes £2,980)

### Example 2: £70,000 Employment Income
- Gross: £70,000
- PA: £12,570
- Taxable: £57,430
- Basic Tax: £10,054 (£50,270 × 20%)
- Higher Tax: £2,864 (£7,160 × 40%)
- NI: £4,594
- Total: £17,512

### Example 3: £150,000 Employment Income
- Gross: £150,000 (above PA withdrawal threshold of £125,140)
- PA withdrawal: (£150,000 - £125,140) × 0.5 = £12,430
- PA: £140 (£12,570 - £12,430)
- Taxable: £149,860
- All three tax bands apply
- Total tax + NI: ~£56,000+

## Constraints (Phase 5a)

### Implemented
- Single employment income → Multiple employments aggregation ✅
- Employment expenses deductions ✅
- Personal Allowance with withdrawal ✅
- Three tax bands (20%, 40%, 45%) ✅
- Class 1 National Insurance (employees) ✅
- Full calculation breakdown ✅

### Not Implemented (Phase 5b+)
- Pension relief calculations → Phase 5b
- Dividend/interest income → Phase 5c
- Self-employment & Class 2/4 NI → Phase 5d
- Marriage Allowance, MCA, foreign tax relief → Phase 5e

## Integration with Exports

Phase 4 export system can be extended to include tax calculation results:

```ruby
# In ExportService, after calculating export:
liability = tax_return.tax_liability
if liability
  # Include liability breakdown in export
  export_data[:tax_calculation] = liability.summary
  export_data[:calculation_steps] = TaxCalculationBreakdown.for_return(tax_return)
end
```

## Next Steps

Phase 5b: Pension Relief
- Pension contribution relief (basic rate, relief at source)
- Recalculate tax after reliefs
- Update export with relief breakdown

Phase 5c: Investment Income
- Dividend income and allowance
- Savings interest and allowance
- Capital Gains Tax
- Higher/additional rate thresholds

Phase 5d: Self-Employment
- Class 2 NI (fixed annual amount)
- Class 4 NI (percentage on profits)
- Trading Allowance
- Partnership allocations

Phase 5e: Advanced Reliefs
- Marriage Allowance transfer
- Married Couple's Allowance
- Non-resident and foreign tax relief
- Trust income

## Files Modified/Created

### Models
- `app/models/tax_band.rb` (NEW)
- `app/models/income_source.rb` (NEW)
- `app/models/tax_liability.rb` (NEW)
- `app/models/tax_calculation_breakdown.rb` (NEW)
- `app/models/tax_return.rb` (MODIFIED - added associations)

### Services
- `app/services/tax_calculations/income_aggregator.rb` (NEW)
- `app/services/tax_calculations/personal_allowance_calculator.rb` (NEW)
- `app/services/tax_calculations/tax_band_calculator.rb` (NEW)
- `app/services/tax_calculations/national_insurance_calculator.rb` (NEW)
- `app/services/tax_calculations/tax_liability_orchestrator.rb` (NEW)

### Migrations
- `db/migrate/20260105100700_create_tax_bands.rb`
- `db/migrate/20260105100800_create_income_sources.rb`
- `db/migrate/20260105100900_create_tax_calculation_breakdowns.rb`
- `db/migrate/20260105101000_create_tax_liabilities.rb`

### Tests (Documented behavior, run with appropriate test framework)
- `spec/services/tax_calculations/personal_allowance_calculator_spec.rb`
- `spec/services/tax_calculations/tax_band_calculator_spec.rb`
- `spec/services/tax_calculations/national_insurance_calculator_spec.rb`
- `spec/services/tax_calculations/tax_liability_orchestrator_spec.rb`

## Configuration

2024-25 defaults auto-loaded via `TaxBand.for_tax_year(2024)`:
- Personal Allowance: £12,570
- Basic Rate: 20% up to £50,270
- Higher Rate: 40% up to £125,140
- Additional Rate: 45%+
- NI Lower: £12,570
- NI Upper: £50,270
- NI Basic: 8%
- NI Higher: 2%

Configurable via database for future tax years.

---

**Status:** Phase 5a Complete (2026-01-05)
**Next Phase:** Phase 5b (Pension Relief)
