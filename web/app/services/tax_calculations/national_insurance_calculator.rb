# frozen_string_literal: true

module TaxCalculations
  class NationalInsuranceCalculator
    def initialize(tax_return)
      @tax_return = tax_return
      @tax_band = TaxBand.for_tax_year(2024)
    end

    def calculate_class_1(employment_income)
      # Class 1 National Insurance (employees)
      # 2024-25: 8% on £12,571-£50,270, then 2% above
      if employment_income <= @tax_band.ni_lower_threshold
        class_1_ni = 0
      elsif employment_income <= @tax_band.ni_upper_threshold
        # All earnings above threshold at basic rate
        taxable_ni = employment_income - @tax_band.ni_lower_threshold
        class_1_ni = taxable_ni * (@tax_band.ni_basic_percentage / 100.0)
      else
        # Basic rate on threshold band, higher rate on excess
        basic_ni_amount = @tax_band.ni_upper_threshold - @tax_band.ni_lower_threshold
        basic_ni = basic_ni_amount * (@tax_band.ni_basic_percentage / 100.0)

        excess_amount = employment_income - @tax_band.ni_upper_threshold
        higher_ni = excess_amount * (@tax_band.ni_higher_percentage / 100.0)

        class_1_ni = basic_ni + higher_ni
      end

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "class_1_ni",
        {
          employment_income: employment_income,
          ni_lower_threshold: @tax_band.ni_lower_threshold,
          ni_upper_threshold: @tax_band.ni_upper_threshold
        },
        class_1_ni,
        "Class 1 NI: £#{format('%.2f', class_1_ni)}"
      )

      class_1_ni
    end
  end
end
