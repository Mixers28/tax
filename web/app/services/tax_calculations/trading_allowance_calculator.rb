module TaxCalculations
  class TradingAllowanceCalculator
    TRADING_ALLOWANCE_2024_25 = 1_000.00

    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      # Only apply if enabled
      return zero_relief_result unless @tax_return.uses_trading_allowance

      # Sum self-employment income
      trading_income = IncomeSource.where(tax_return: @tax_return)
        .where(source_type: :self_employment)
        .sum(:amount_gross)
        .to_f

      # Allowance is lesser of £1,000 or actual income
      allowance_amount = [trading_income, TRADING_ALLOWANCE_2024_25].min
      net_income = trading_income - allowance_amount

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "trading_allowance",
        { trading_income: trading_income, allowance: allowance_amount },
        net_income,
        "Trading Allowance: £#{format('%.2f', allowance_amount)} deducted from trading income of £#{format('%.2f', trading_income)}"
      )

      {
        trading_income_gross: trading_income,
        trading_allowance_amount: allowance_amount,
        trading_income_net: net_income
      }
    end

    private

    def zero_relief_result
      { trading_income_gross: 0, trading_allowance_amount: 0, trading_income_net: 0 }
    end
  end
end
