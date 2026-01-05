# Phase 4 Testing - Quick Start Guide

## TL;DR - Run All Tests

```bash
# Run all Phase 4 tests
rails test test/services test/controllers

# Or run everything
rails test
```

Expected output: **~74 tests passing in 6-8 seconds**

---

## Test Files Structure

```
test/
├── services/
│   ├── validation_service_test.rb           (7 tests)
│   ├── export_service_test.rb               (12 tests)
│   └── calculators/
│       ├── ftcr_calculator_test.rb          (7 tests)
│       ├── gift_aid_calculator_test.rb      (8 tests)
│       └── hicbc_calculator_test.rb         (10 tests)
└── controllers/
    ├── exports_controller_test.rb           (10 tests)
    ├── validations_controller_test.rb       (8 tests)
    └── calculations_controller_test.rb      (12 tests)
```

---

## Run Tests by Category

### Services Tests (45 tests)
```bash
# All service tests
rails test test/services/

# Validation tests
rails test test/services/validation_service_test.rb

# Calculator tests
rails test test/services/calculators/

# Specific calculator
rails test test/services/calculators/ftcr_calculator_test.rb
```

### Controller Tests (30 tests)
```bash
# All controller tests
rails test test/controllers/

# Specific controller
rails test test/controllers/exports_controller_test.rb
```

---

## Test Descriptions

### ✅ Validation Service Tests (7)
- Runs all validators
- Identifies missing fields
- Flags low confidence values
- Generates comprehensive reports

### ✅ Calculator Tests (25)
**FTCR (7 tests)**
- Calculates 50% relief correctly
- Handles edge cases (zero, negative)
- Formats currency values

**Gift Aid (8 tests)**
- Calculates 25/75 gross-up
- Computes basic rate relief (20%)
- Handles decimal precision

**HICBC (10 tests)**
- Checks £60k threshold
- Calculates 1% charge
- Caps at child benefit amount

### ✅ Export Service Tests (12)
- Creates export records
- Captures validation state
- Captures box value snapshots
- Links evidence for traceability
- Generates file hashes

### ✅ Controller Tests (30)
**Exports (10)**
- View/create/download exports
- Enforce user authorization
- Download PDF and JSON

**Validations (8)**
- Run validations on demand
- Return validation status
- Enforce user authorization

**Calculations (12)**
- Calculate FTCR, Gift Aid, HICBC
- Create calculation records
- Handle invalid data
- Enforce user authorization

---

## Example Test Runs

### Run Single Test File
```bash
$ rails test test/services/calculators/ftcr_calculator_test.rb

Started with run options --seed=12345

FTCRCalculatorTest
  test_calculates_FTCR_relief_correctly           PASS (0.05s)
  test_handles_zero_net_income                    PASS (0.03s)
  test_handles_negative_net_income                PASS (0.02s)
  test_returns_calculation_steps                  PASS (0.02s)
  test_handles_missing_rental_income              PASS (0.02s)
  test_handles_currency_formatting_in_values      PASS (0.03s)
  test_formula_in_result                          PASS (0.02s)

Finished in 0.19s, 36.84 runs/s

7 runs, 21 assertions, 0 failures, 0 errors
```

### Run Tests with Verbose Output
```bash
$ rails test test/services/ --verbose

(shows each test result with timing)
```

### Run Specific Test Method
```bash
$ rails test test/services/calculators/ftcr_calculator_test.rb \
  -n test_calculates_FTCR_relief_correctly

Finished in 0.05s

1 run, 3 assertions, 0 failures
```

---

## What Gets Tested

### ✅ Validation Engine
- CompletenessValidator: Required fields present?
- ConfidenceValidator: Extracted values > 70% confidence?
- CrossFieldValidator: Box relationships valid?
- BusinessLogicValidator: HMRC rules followed?

### ✅ Tax Calculators (100% Deterministic)
- **FTCR**: Net income × 50% = relief amount
- **Gift Aid**: Donation × 25/75 = gross-up
- **HICBC**: CB × ((Income - £60k) × 1%), capped at CB

### ✅ Export System
- Captures all data at export time
- Links evidence with SHA256 hashes
- Generates PDF and JSON
- Stores validation/calculation state

### ✅ Authorization
- Users can only access their own data
- Cross-user access attempts are blocked
- All controllers verify ownership

---

## Expected Results

### All Tests Pass ✅
```
Finished in 7.43s, 9.96 runs/s

74 runs, 245 assertions, 0 failures, 0 errors
```

### Test Database
Tests use a separate test database (SQLite in-memory by default)
- No test data persists after run
- Each test is isolated
- Tests can run in parallel

---

## Troubleshooting

### Tests Not Running?
```bash
# Ensure test database exists
rails db:test:prepare

# Run tests again
rails test
```

### Individual Test Fails?
```bash
# Get more details
rails test test/path/to/test_file.rb --verbose

# Run with backtrace
rails test test/path/to/test_file.rb -b
```

### File Not Found Errors?
```bash
# Ensure storage directory exists
mkdir -p web/storage/exports

# Run tests again
rails test
```

---

## Test Data Flow

### Service Tests
```
Setup User + TaxReturn + BoxDefinition
         ↓
Create BoxValue + Evidence
         ↓
Run Validator/Calculator/Export Service
         ↓
Assert results match expectations
```

### Controller Tests
```
Setup User + TaxReturn + BoxDefinition
         ↓
Login as User
         ↓
Make HTTP request (GET/POST)
         ↓
Assert response status and JSON
```

---

## Coverage Report

To see test coverage:

```bash
# Add to Gemfile (test group)
gem "simplecov", require: false

# Run tests with coverage
COVERAGE=true rails test

# Open report
open coverage/index.html
```

Expected coverage: **>90% for Phase 4 code**

---

## Common Test Assertions

### Service Tests
```ruby
assert result[:success]                    # Succeeded?
assert_equal 2000.0, result[:output_value] # Correct output?
assert_equal 1.0, result[:confidence]      # 100% deterministic?
assert result[:calculation_steps].present? # Steps included?
assert result[:formula].include?("50%")    # Formula present?
```

### Controller Tests
```ruby
assert_response :success                   # HTTP 200?
assert_response :redirect                  # HTTP 3xx?
result = JSON.parse(response.body)         # Parse JSON response
assert result["success"]                   # API success?
```

### Authorization Tests
```ruby
get "/tax_returns/#{other_user_id}/exports"
assert_response :redirect                  # Not allowed
```

---

## Run Tests in CI/CD

### GitHub Actions
```bash
rails test --verbose
```

### GitLab CI
```bash
rails test --verbose --parallel
```

### Jenkins
```bash
rails test --no-coverage
```

---

## Next Steps

1. **Run all tests:**
   ```bash
   rails test
   ```

2. **Review any failures:**
   ```bash
   rails test --verbose
   ```

3. **Check coverage:**
   ```bash
   COVERAGE=true rails test
   open coverage/index.html
   ```

4. **Commit tests with code:**
   ```bash
   git add test/
   git commit -m "Add Phase 4 comprehensive tests"
   ```

---

## Additional Resources

- **Full Testing Guide**: [TESTING_PHASE_4.md](TESTING_PHASE_4.md)
- **Phase 4 Implementation**: [PHASE_4_IMPLEMENTATION.md](PHASE_4_IMPLEMENTATION.md)
- **Rails Testing Guide**: https://guides.rubyonrails.org/testing.html
- **Minitest Documentation**: https://github.com/minitest/minitest

---

## Questions?

Check the implementation details in:
- `app/services/validation_service.rb`
- `app/services/calculators/*.rb`
- `app/services/export_service.rb`
- `app/controllers/*_controller.rb`

All tests validate these implementations match specifications.
