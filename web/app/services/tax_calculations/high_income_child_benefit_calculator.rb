# frozen_string_literal: true

module TaxCalculations
  class HighIncomeChildBenefitCalculator
    HICBC_THRESHOLD = 60_000.00
    HICBC_RATE = 0.01 # 1% of child benefit for every £1 above threshold

    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # High Income Child Benefit Charge (HICBC)
      # 2024-25: If net income > £60,000, charge = 1% of child benefit for every £1 above threshold
      # Maximum charge = 100% of child benefit received

      # Use total gross income as proxy for net income
      net_income = IncomeSource
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      # Check if income threshold is exceeded
      return zero_charge_result(net_income) if net_income <= HICBC_THRESHOLD

      # Calculate excess income
      excess_income = (net_income - HICBC_THRESHOLD).round(2)

      # For now, we don't have child benefit amount stored
      # In a real scenario, this would come from SA100 form or user input
      # For calculation purposes, we'll return the charge percentage and let the orchestrator handle it
      charge_percentage = (excess_income * HICBC_RATE).round(4)

      # Record breakdown step
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "hicbc_charge",
        {
          net_income: net_income,
          hicbc_threshold: HICBC_THRESHOLD,
          excess_income: excess_income,
          charge_percentage: charge_percentage
        },
        excess_income,
        "HICBC: Income £#{format('%.2f', net_income)} exceeds threshold by £#{format('%.2f', excess_income)} (charge percentage: #{(charge_percentage * 100).round(2)}%)"
      )

      {
        net_income: net_income,
        hicbc_threshold: HICBC_THRESHOLD,
        excess_income: excess_income,
        charge_percentage: charge_percentage,
        # Actual charge depends on child benefit amount (not available here)
        hicbc_charge: 0
      }
    end

    private

    def zero_charge_result(net_income)
      {
        net_income: net_income,
        hicbc_threshold: HICBC_THRESHOLD,
        excess_income: 0,
        charge_percentage: 0,
        hicbc_charge: 0
      }
    end
  end
end
