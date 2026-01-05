# frozen_string_literal: true

module TaxCalculations
  class TaxBandCalculator
    def initialize(tax_return)
      @tax_return = tax_return
      @tax_band = TaxBand.for_tax_year(2024)
    end

    def calculate(taxable_income)
      basic_rate_tax = 0
      higher_rate_tax = 0
      additional_rate_tax = 0

      if taxable_income <= 0
        # No tax
      elsif taxable_income <= @tax_band.basic_rate_limit
        # All income in basic rate band
        basic_rate_tax = taxable_income * (@tax_band.basic_rate_percentage / 100.0)
      elsif taxable_income <= @tax_band.higher_rate_limit
        # Basic rate on first £50,270, higher rate on excess
        basic_rate_tax = @tax_band.basic_rate_limit * (@tax_band.basic_rate_percentage / 100.0)
        higher_amount = taxable_income - @tax_band.basic_rate_limit
        higher_rate_tax = higher_amount * (@tax_band.higher_rate_percentage / 100.0)
      else
        # All three bands
        basic_rate_tax = @tax_band.basic_rate_limit * (@tax_band.basic_rate_percentage / 100.0)
        higher_amount = @tax_band.higher_rate_limit - @tax_band.basic_rate_limit
        higher_rate_tax = higher_amount * (@tax_band.higher_rate_percentage / 100.0)
        additional_amount = taxable_income - @tax_band.higher_rate_limit
        additional_rate_tax = additional_amount * (@tax_band.additional_rate_percentage / 100.0)
      end

      total_tax = basic_rate_tax + higher_rate_tax + additional_rate_tax

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "tax_band_calculation",
        {
          taxable_income: taxable_income,
          basic_rate_limit: @tax_band.basic_rate_limit,
          higher_rate_limit: @tax_band.higher_rate_limit
        },
        total_tax,
        "Income Tax: Basic £#{format('%.2f', basic_rate_tax)} + Higher £#{format('%.2f', higher_rate_tax)} + Additional £#{format('%.2f', additional_rate_tax)} = £#{format('%.2f', total_tax)}"
      )

      {
        basic_rate_tax: basic_rate_tax,
        higher_rate_tax: higher_rate_tax,
        additional_rate_tax: additional_rate_tax,
        total_income_tax: total_tax
      }
    end
  end
end
