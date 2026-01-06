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

    def calculate_class_2(self_employment_income)
      # Class 2 National Insurance (self-employed)
      # 2024-25: Fixed £163.80 per year if profit > £6,725 (threshold)
      # £0 if profit ≤ £6,725

      CLASS_2_NI_FIXED = 163.80
      CLASS_2_NI_THRESHOLD = 6_725.00

      class_2_ni = self_employment_income > CLASS_2_NI_THRESHOLD ? CLASS_2_NI_FIXED : 0

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "class_2_ni",
        {
          self_employment_income: self_employment_income,
          class_2_threshold: CLASS_2_NI_THRESHOLD
        },
        class_2_ni,
        "Class 2 NI: £#{format('%.2f', class_2_ni)}"
      )

      class_2_ni
    end

    def calculate_class_4(profit)
      # Class 4 National Insurance (self-employed)
      # 2024-25: 8% on £12,571-£50,270, then 2% above
      # £0 if profit ≤ £12,570

      CLASS_4_LOWER_THRESHOLD = 12_570.00
      CLASS_4_UPPER_THRESHOLD = 50_270.00
      CLASS_4_BASIC_RATE = 0.08
      CLASS_4_HIGHER_RATE = 0.02

      return zero_class_4_result if profit <= CLASS_4_LOWER_THRESHOLD

      if profit <= CLASS_4_UPPER_THRESHOLD
        # All profit in basic rate
        class_4_ni = (profit - CLASS_4_LOWER_THRESHOLD) * CLASS_4_BASIC_RATE
      else
        # Basic rate on lower band, higher rate on excess
        basic_profit = CLASS_4_UPPER_THRESHOLD - CLASS_4_LOWER_THRESHOLD
        basic_ni = basic_profit * CLASS_4_BASIC_RATE

        excess_profit = profit - CLASS_4_UPPER_THRESHOLD
        higher_ni = excess_profit * CLASS_4_HIGHER_RATE

        class_4_ni = basic_ni + higher_ni
      end

      class_4_ni = class_4_ni.round(2)

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "class_4_ni",
        {
          self_employment_profit: profit,
          class_4_lower_threshold: CLASS_4_LOWER_THRESHOLD,
          class_4_upper_threshold: CLASS_4_UPPER_THRESHOLD
        },
        class_4_ni,
        "Class 4 NI: £#{format('%.2f', class_4_ni)}"
      )

      class_4_ni
    end

    private

    def zero_class_4_result
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "class_4_ni",
        { self_employment_profit: 0 },
        0,
        "Class 4 NI: £0.00"
      )
      0
    end
  end
end
