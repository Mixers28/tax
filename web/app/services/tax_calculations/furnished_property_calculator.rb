# frozen_string_literal: true

module TaxCalculations
  class FurnishedPropertyCalculator
    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Furnished Temporary Accommodation Relief (FTCR)
      # 2024-25: Relief = 50% of net rental income (maximum)

      # Collect rental property income from IncomeSource
      rental_income = IncomeSource
        .where(tax_return: @tax_return, source_type: :rental_property)
        .sum(:amount_gross)
        .to_f

      return zero_relief_result if rental_income <= 0

      # Calculate relief: 50% of net income
      # Assuming net rental income = gross (simplified for now)
      ftcr_relief = (rental_income * 0.5).round(2)

      # Record breakdown step
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "furnished_property_relief",
        {
          rental_income: rental_income,
          relief_percentage: 50.0
        },
        ftcr_relief,
        "Furnished Property Relief: £#{format('%.2f', rental_income)} × 50% = £#{format('%.2f', ftcr_relief)}"
      )

      {
        rental_income: rental_income,
        ftcr_relief: ftcr_relief,
        taxable_rental_income: (rental_income - ftcr_relief).round(2)
      }
    end

    private

    def zero_relief_result
      {
        rental_income: 0,
        ftcr_relief: 0,
        taxable_rental_income: 0
      }
    end
  end
end
