module TaxCalculations
  class MarriageAllowanceCalculator
    MARRIAGE_ALLOWANCE_2024_25 = 1_260.00 # 10% of PA
    BASIC_RATE = 0.20

    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Only apply if claimed
      return zero_relief_result unless @tax_return.claims_marriage_allowance

      role = @tax_return.marriage_allowance_role
      transfer_amount = MARRIAGE_ALLOWANCE_2024_25

      # Tax reduction only for transferee (receiver)
      tax_reduction = role == "transferee" ? (transfer_amount * BASIC_RATE) : 0

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "marriage_allowance",
        { role: role, transfer_amount: transfer_amount },
        tax_reduction,
        "Marriage Allowance: #{role.capitalize} - £#{format('%.2f', transfer_amount)} PA #{role == 'transferor' ? 'transferred out' : 'received'}"
      )

      {
        transfer_amount: transfer_amount,
        tax_reduction: tax_reduction,
        pa_adjustment: role == "transferor" ? -transfer_amount : transfer_amount
      }
    end

    private

    def zero_relief_result
      { transfer_amount: 0, tax_reduction: 0, pa_adjustment: 0 }
    end
  end
end
