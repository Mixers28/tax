# frozen_string_literal: true

module TaxCalculations
  class PensionReliefCalculator
    ANNUAL_ALLOWANCE = 60_000.00

    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Sum net contributions
      net_contributions = IncomeSource.pension_contributions
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      # Gross-up: net / 0.8 = gross (relief at source)
      gross_contributions = net_contributions.zero? ? 0 : (net_contributions / 0.8)
      relief_at_source = gross_contributions - net_contributions
      allowance_exceeded = gross_contributions > ANNUAL_ALLOWANCE

      # Record breakdown step
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "pension_relief",
        {
          net_contributions: net_contributions,
          gross_contributions: gross_contributions,
          relief_at_source: relief_at_source,
          annual_allowance: ANNUAL_ALLOWANCE,
          allowance_exceeded: allowance_exceeded
        },
        relief_at_source,
        "Pension Relief: £#{format('%.2f', relief_at_source)} (contributions £#{format('%.2f', net_contributions)} grossed to £#{format('%.2f', gross_contributions)})"
      )

      {
        net_contributions: net_contributions,
        gross_contributions: gross_contributions,
        relief_at_source: relief_at_source,
        allowance_exceeded: allowance_exceeded
      }
    end
  end
end
