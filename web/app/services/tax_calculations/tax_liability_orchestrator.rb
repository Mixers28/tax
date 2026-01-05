# frozen_string_literal: true

module TaxCalculations
  class TaxLiabilityOrchestrator
    def initialize(tax_return)
      @tax_return = tax_return
    end

    # Main calculation entry point for Phase 5a (basic employment income)
    def calculate
      # Phase 5a: Basic employment income + tax + NI
      gross_income = IncomeAggregator.new(@tax_return).calculate
      tax_paid_at_source = IncomeSource.total_tax_taken(@tax_return)

      # Personal Allowance
      pa_calculator = PersonalAllowanceCalculator.new(@tax_return)
      personal_allowance = pa_calculator.calculate(gross_income)

      # Taxable income
      taxable_income = [gross_income - personal_allowance, 0].max
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "taxable_income",
        { gross_income: gross_income, personal_allowance: personal_allowance },
        taxable_income,
        "Taxable Income: £#{format('%.2f', taxable_income)}"
      )

      # Income tax by band
      tax_result = TaxBandCalculator.new(@tax_return).calculate(taxable_income)

      # Class 1 National Insurance (only on employment income for Phase 5a)
      employment_income = IncomeSource.employment
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      class_1_ni = NationalInsuranceCalculator.new(@tax_return).calculate_class_1(employment_income)

      # Create or update TaxLiability record
      liability = TaxLiability.for_return(@tax_return)
      liability.update!(
        total_gross_income: gross_income,
        taxable_income: taxable_income,
        basic_rate_tax: tax_result[:basic_rate_tax],
        higher_rate_tax: tax_result[:higher_rate_tax],
        additional_rate_tax: tax_result[:additional_rate_tax],
        total_income_tax: tax_result[:total_income_tax],
        class_1_ni: class_1_ni,
        class_2_ni: 0,
        class_4_ni: 0,
        tax_paid_at_source: tax_paid_at_source,
        calculated_by: "auto",
        calculated_at: Time.current
      )

      # Record final summary
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "final_liability",
        {
          total_income_tax: tax_result[:total_income_tax],
          total_ni: class_1_ni,
          tax_paid_at_source: tax_paid_at_source
        },
        liability.net_liability,
        "Net Liability: £#{format('%.2f', liability.net_liability)}"
      )

      liability
    end
  end
end
