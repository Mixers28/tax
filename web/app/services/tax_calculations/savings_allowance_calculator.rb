# frozen_string_literal: true

module TaxCalculations
  class SavingsAllowanceCalculator
    # Personal Savings Allowance (PSA) amounts for 2024-25
    PSA_BASIC_RATE = 1_000.00
    PSA_HIGHER_RATE = 500.00
    PSA_ADDITIONAL_RATE = 0.00

    def initialize(tax_return)
      @tax_return = tax_return
      @tax_band = TaxBand.for_tax_year(2024)
    end

    def calculate(non_savings_income)
      # Sum all savings interest
      savings_interest_gross = IncomeSource.interest
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      # Return zero if no interest
      return zero_result if savings_interest_gross <= 0

      # Determine PSA based on marginal tax rate
      # Marginal rate is determined by non-savings income position
      psa_amount = calculate_psa_for_rate(non_savings_income)

      # Allowance is lesser of PSA or actual interest
      allowance_amount = [savings_interest_gross, psa_amount].min
      taxable_interest = [savings_interest_gross - allowance_amount, 0].max

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "savings_allowance",
        {
          savings_interest_gross: savings_interest_gross,
          non_savings_income: non_savings_income,
          psa_amount: psa_amount,
          allowance: allowance_amount
        },
        taxable_interest,
        "Personal Savings Allowance: £#{format('%.2f', allowance_amount)} (#{rate_description(psa_amount)}) deducted from interest of £#{format('%.2f', savings_interest_gross)}"
      )

      {
        savings_interest_gross: savings_interest_gross,
        savings_allowance_amount: allowance_amount,
        savings_interest_taxable: taxable_interest
      }
    end

    private

    def calculate_psa_for_rate(non_savings_income)
      # PSA depends on marginal tax rate BEFORE savings income is added
      pa_total = @tax_return.tax_liability&.personal_allowance_total || @tax_band.pa_amount
      taxable_non_savings = [non_savings_income - pa_total, 0].max

      if taxable_non_savings <= @tax_band.basic_rate_limit
        # Basic rate taxpayer: £1,000 PSA
        PSA_BASIC_RATE
      elsif taxable_non_savings <= @tax_band.higher_rate_limit
        # Higher rate taxpayer: £500 PSA
        PSA_HIGHER_RATE
      else
        # Additional rate taxpayer: £0 PSA
        PSA_ADDITIONAL_RATE
      end
    end

    def rate_description(psa_amount)
      case psa_amount
      when PSA_BASIC_RATE
        "basic rate taxpayer"
      when PSA_HIGHER_RATE
        "higher rate taxpayer"
      else
        "additional rate taxpayer"
      end
    end

    def zero_result
      {
        savings_interest_gross: 0,
        savings_allowance_amount: 0,
        savings_interest_taxable: 0
      }
    end
  end
end
