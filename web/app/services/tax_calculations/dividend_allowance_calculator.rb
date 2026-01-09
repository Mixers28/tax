# frozen_string_literal: true

module TaxCalculations
  class DividendAllowanceCalculator
    DIVIDEND_ALLOWANCE_2024_25 = 500.00

    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Sum all dividend income
      dividend_income_gross = IncomeSource.dividends
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      # Return zero if no dividends
      return zero_result if dividend_income_gross <= 0

      # Allowance is lesser of £500 or actual dividends
      allowance_amount = [dividend_income_gross, DIVIDEND_ALLOWANCE_2024_25].min
      taxable_dividends = [dividend_income_gross - allowance_amount, 0].max

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "dividend_allowance",
        {
          dividend_income_gross: dividend_income_gross,
          allowance: allowance_amount
        },
        taxable_dividends,
        "Dividend Allowance: £#{format('%.2f', allowance_amount)} deducted from dividends of £#{format('%.2f', dividend_income_gross)}"
      )

      {
        dividend_income_gross: dividend_income_gross,
        dividend_allowance_amount: allowance_amount,
        dividend_income_taxable: taxable_dividends
      }
    end

    private

    def zero_result
      {
        dividend_income_gross: 0,
        dividend_allowance_amount: 0,
        dividend_income_taxable: 0
      }
    end
  end
end
