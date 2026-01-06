# frozen_string_literal: true

module TaxCalculations
  class TaxLiabilityOrchestrator
    def initialize(tax_return)
      @tax_return = tax_return
    end

    # Main calculation entry point for Phase 5b (employment + pension relief + gift aid + blind allowance)
    def calculate
      # Phase 5b: Employment income + pension relief + gift aid + blind allowance + tax + NI
      gross_income = IncomeAggregator.new(@tax_return).calculate
      tax_paid_at_source = IncomeSource.total_tax_taken(@tax_return)

      # Personal Allowance + Blind Allowance
      pa_calculator = PersonalAllowanceCalculator.new(@tax_return)
      pa_result = pa_calculator.calculate(gross_income)
      personal_allowance = pa_result[:total_pa]

      # Pension Relief
      pension_result = PensionReliefCalculator.new(@tax_return).calculate
      pension_relief = pension_result[:gross_contributions]

      # Taxable income (after PA and pension relief)
      taxable_income = [gross_income - personal_allowance - pension_relief, 0].max
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "taxable_income",
        {
          gross_income: gross_income,
          personal_allowance: personal_allowance,
          pension_relief: pension_relief
        },
        taxable_income,
        "Taxable Income: £#{format('%.2f', taxable_income)}"
      )

      # Gift Aid band extension
      gift_aid_result = GiftAidCalculator.new(@tax_return).calculate
      gift_aid_band_extension = gift_aid_result[:band_extension]

      # Income tax by band (with gift aid band extension)
      tax_result = TaxBandCalculator.new(@tax_return).calculate(
        taxable_income,
        gift_aid_band_extension: gift_aid_band_extension
      )

      # Class 1 National Insurance (only on employment income)
      employment_income = IncomeSource.employment
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      class_1_ni = NationalInsuranceCalculator.new(@tax_return).calculate_class_1(employment_income)

      # Self-employment income
      self_employment_income = IncomeSource.self_employment
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f

      # Class 2 & 4 National Insurance (for self-employed)
      ni_calculator = NationalInsuranceCalculator.new(@tax_return)
      class_2_ni = self_employment_income > 0 ? ni_calculator.calculate_class_2(self_employment_income) : 0
      class_4_ni = self_employment_income > 0 ? ni_calculator.calculate_class_4(self_employment_income) : 0

      # Furnished Property Relief (FTCR)
      ftcr_result = FurnishedPropertyCalculator.new(@tax_return).calculate
      furnished_relief = ftcr_result[:ftcr_relief]

      # High Income Child Benefit Charge (HICBC)
      hicbc_result = HighIncomeChildBenefitCalculator.new(@tax_return).calculate
      hicbc_charge = hicbc_result[:hicbc_charge]

      # Phase 5d: Trading Allowance
      trading_result = TradingAllowanceCalculator.new(@tax_return).calculate

      # Phase 5d: Marriage Allowance (already integrated in PA calculator, but get standalone result)
      marriage_allowance_result = MarriageAllowanceCalculator.new(@tax_return).calculate

      # Phase 5d: Married Couple's Allowance (applied as tax credit)
      mca_result = MarriedCouplesAllowanceCalculator.new(@tax_return).calculate
      mca_relief = mca_result[:relief_amount]

      # Calculate final tax after MCA relief
      final_income_tax = [tax_result[:total_income_tax] - mca_relief, 0].max

      # Create or update TaxLiability record
      liability = TaxLiability.for_return(@tax_return)
      liability.update!(
        total_gross_income: gross_income,
        personal_allowance_base: pa_result[:base_pa],
        blind_persons_allowance: pa_result[:blind_allowance],
        personal_allowance_total: personal_allowance,
        pension_contributions_gross: pension_result[:gross_contributions],
        pension_relief_at_source: pension_result[:relief_at_source],
        gift_aid_donations_net: gift_aid_result[:donations_net],
        gift_aid_gross_up: gift_aid_result[:gross_up],
        gift_aid_extended_band: gift_aid_band_extension,
        rental_property_income: ftcr_result[:rental_income],
        furnished_property_relief: furnished_relief,
        self_employment_income: self_employment_income,
        hicbc_threshold_income: hicbc_result[:net_income],
        hicbc_charge: hicbc_charge,
        # Phase 5d: Trading Allowance
        trading_income_gross: trading_result[:trading_income_gross],
        trading_allowance_amount: trading_result[:trading_allowance_amount],
        trading_income_net: trading_result[:trading_income_net],
        # Phase 5d: Marriage Allowance
        marriage_allowance_transfer_amount: marriage_allowance_result[:transfer_amount],
        marriage_allowance_tax_reduction: marriage_allowance_result[:tax_reduction],
        # Phase 5d: Married Couple's Allowance
        married_couples_allowance_amount: mca_result[:allowance_amount],
        married_couples_allowance_relief: mca_result[:relief_amount],
        taxable_income: taxable_income,
        basic_rate_tax: tax_result[:basic_rate_tax],
        higher_rate_tax: tax_result[:higher_rate_tax],
        additional_rate_tax: tax_result[:additional_rate_tax],
        total_income_tax: final_income_tax,
        class_1_ni: class_1_ni,
        class_2_ni: class_2_ni,
        class_4_ni: class_4_ni,
        tax_paid_at_source: tax_paid_at_source,
        calculated_by: "auto",
        calculated_at: Time.current
      )

      # Record final summary
      total_ni = class_1_ni + class_2_ni + class_4_ni
      TaxCalculationBreakdown.record_step(
        @tax_return,
        "final_liability",
        {
          total_income_tax: tax_result[:total_income_tax],
          class_1_ni: class_1_ni,
          class_2_ni: class_2_ni,
          class_4_ni: class_4_ni,
          total_ni: total_ni,
          furnished_property_relief: furnished_relief,
          hicbc_charge: hicbc_charge,
          tax_paid_at_source: tax_paid_at_source
        },
        liability.net_liability,
        "Net Liability: £#{format('%.2f', liability.net_liability)}"
      )

      liability
    end
  end
end
