module TaxCalculations
  class MarriedCouplesAllowanceCalculator
    MCA_AMOUNT_2024_25 = 11_080.00
    MCA_MINIMUM_2024_25 = 4_280.00
    INCOME_LIMIT = 37_000.00
    RELIEF_RATE = 0.10

    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Only apply if claimed and eligible
      return zero_relief_result unless @tax_return.claims_married_couples_allowance

      # Check age eligibility (born before 6 April 1935)
      return zero_relief_result unless eligible_by_age?

      net_income = calculate_net_income
      allowance = calculate_allowance(net_income)
      relief = allowance * RELIEF_RATE

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "married_couples_allowance",
        { net_income: net_income, allowance: allowance, relief_rate: RELIEF_RATE },
        relief,
        "Married Couple's Allowance: £#{format('%.2f', allowance)} × 10% = £#{format('%.2f', relief)} tax reduction"
      )

      {
        allowance_amount: allowance,
        relief_amount: relief
      }
    end

    private

    def eligible_by_age?
      return false unless @tax_return.spouse_dob.present?

      # Born before 6 April 1935 means 90+ years old in 2024-25
      cutoff_date = Date.new(1935, 4, 6)
      @tax_return.spouse_dob < cutoff_date
    end

    def calculate_net_income
      # Use adjusted net income (after PA and reliefs)
      @tax_return.tax_liability&.taxable_income || 0
    end

    def calculate_allowance(net_income)
      return MCA_AMOUNT_2024_25 if net_income <= INCOME_LIMIT

      # Reduce by £1 for every £2 over threshold
      reduction = ((net_income - INCOME_LIMIT) / 2.0).floor
      allowance = MCA_AMOUNT_2024_25 - reduction

      # Cannot go below minimum
      [allowance, MCA_MINIMUM_2024_25].max
    end

    def zero_relief_result
      { allowance_amount: 0, relief_amount: 0 }
    end
  end
end
