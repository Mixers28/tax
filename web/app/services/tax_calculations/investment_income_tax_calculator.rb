# frozen_string_literal: true

module TaxCalculations
  class InvestmentIncomeTaxCalculator
    # Dividend tax rates for 2024-25
    DIVIDEND_BASIC_RATE = 0.0875      # 8.75%
    DIVIDEND_HIGHER_RATE = 0.3375     # 33.75%
    DIVIDEND_ADDITIONAL_RATE = 0.3935 # 39.35%

    def initialize(tax_return)
      @tax_return = tax_return
      @tax_band = TaxBand.for_tax_year(2024)
    end

    def calculate(non_savings_income, taxable_savings, taxable_dividends)
      # Calculate how much of each tax band is already used by non-savings income
      pa_total = @tax_return.tax_liability&.personal_allowance_total || @tax_band.pa_amount

      # Income after PA
      income_after_pa = [non_savings_income - pa_total, 0].max

      # Track band usage
      basic_used = [income_after_pa, @tax_band.basic_rate_limit].min
      higher_used = [[income_after_pa - @tax_band.basic_rate_limit, 0].max, @tax_band.higher_rate_limit - @tax_band.basic_rate_limit].min

      # Calculate savings interest tax (standard rates, after PSA)
      savings_tax = calculate_savings_tax(taxable_savings, basic_used, higher_used)

      # Update band usage after savings
      savings_in_basic = [[@tax_band.basic_rate_limit - basic_used, 0].max, taxable_savings].min
      savings_in_higher = [[@tax_band.higher_rate_limit - @tax_band.basic_rate_limit - higher_used, 0].max, [taxable_savings - savings_in_basic, 0].max].min

      basic_used += savings_in_basic
      higher_used += savings_in_higher

      # Calculate dividend tax (dividend rates, after allowance)
      dividend_result = calculate_dividend_tax(taxable_dividends, basic_used, higher_used)

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "investment_income_tax",
        {
          taxable_savings: taxable_savings,
          taxable_dividends: taxable_dividends,
          savings_tax: savings_tax,
          total_dividend_tax: dividend_result[:total]
        },
        savings_tax + dividend_result[:total],
        "Investment Income Tax: £#{format('%.2f', savings_tax)} (savings) + £#{format('%.2f', dividend_result[:total])} (dividends)"
      )

      {
        savings_interest_tax: savings_tax,
        dividend_basic_rate_tax: dividend_result[:basic],
        dividend_higher_rate_tax: dividend_result[:higher],
        dividend_additional_rate_tax: dividend_result[:additional],
        total_dividend_tax: dividend_result[:total]
      }
    end

    private

    def calculate_savings_tax(taxable_savings, basic_used, higher_used)
      return 0 if taxable_savings <= 0

      # How much room in each band?
      basic_remaining = [@tax_band.basic_rate_limit - basic_used, 0].max
      higher_remaining = [@tax_band.higher_rate_limit - @tax_band.basic_rate_limit - higher_used, 0].max

      # Allocate savings to bands
      savings_in_basic = [basic_remaining, taxable_savings].min
      savings_in_higher = [higher_remaining, [taxable_savings - savings_in_basic, 0].max].min
      savings_in_additional = [taxable_savings - savings_in_basic - savings_in_higher, 0].max

      # Calculate tax at standard rates
      basic_tax = savings_in_basic * @tax_band.basic_rate_percentage / 100.0
      higher_tax = savings_in_higher * @tax_band.higher_rate_percentage / 100.0
      additional_tax = savings_in_additional * @tax_band.additional_rate_percentage / 100.0

      (basic_tax + higher_tax + additional_tax).round(2)
    end

    def calculate_dividend_tax(taxable_dividends, basic_used, higher_used)
      return { basic: 0, higher: 0, additional: 0, total: 0 } if taxable_dividends <= 0

      # How much room in each band?
      basic_remaining = [@tax_band.basic_rate_limit - basic_used, 0].max
      higher_remaining = [@tax_band.higher_rate_limit - @tax_band.basic_rate_limit - higher_used, 0].max

      # Allocate dividends to bands
      div_in_basic = [basic_remaining, taxable_dividends].min
      div_in_higher = [higher_remaining, [taxable_dividends - div_in_basic, 0].max].min
      div_in_additional = [taxable_dividends - div_in_basic - div_in_higher, 0].max

      # Calculate tax at dividend rates
      basic_tax = (div_in_basic * DIVIDEND_BASIC_RATE).round(2)
      higher_tax = (div_in_higher * DIVIDEND_HIGHER_RATE).round(2)
      additional_tax = (div_in_additional * DIVIDEND_ADDITIONAL_RATE).round(2)

      {
        basic: basic_tax,
        higher: higher_tax,
        additional: additional_tax,
        total: basic_tax + higher_tax + additional_tax
      }
    end
  end
end
