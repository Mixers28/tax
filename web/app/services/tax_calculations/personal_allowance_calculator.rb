# frozen_string_literal: true

module TaxCalculations
  class PersonalAllowanceCalculator
    # 2024-25: PA frozen at £12,570 regardless of age
    PA_2024_25 = 12_570.00
    PA_WITHDRAWAL_THRESHOLD = 125_140.00
    PA_WITHDRAWAL_RATE = 0.50  # Withdraw £1 for every £2 above threshold

    def initialize(tax_return)
      @tax_return = tax_return
      @tax_band = TaxBand.for_tax_year(2024)
    end

    def calculate(gross_income)
      pa = base_allowance

      # Phase 5a: Withdraw PA if income > £125,140
      if gross_income > PA_WITHDRAWAL_THRESHOLD
        withdrawal = (gross_income - PA_WITHDRAWAL_THRESHOLD) * PA_WITHDRAWAL_RATE
        pa = [pa - withdrawal, 0].max
      end

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "personal_allowance",
        {
          gross_income: gross_income,
          base_pa: base_allowance,
          withdrawal_threshold: PA_WITHDRAWAL_THRESHOLD
        },
        pa,
        "Personal Allowance: £#{format('%.2f', pa)}"
      )

      pa
    end

    private

    def base_allowance
      @tax_band.pa_amount
    end
  end
end
