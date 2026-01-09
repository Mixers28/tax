# frozen_string_literal: true

module TaxCalculations
  class IncomeAggregator
    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      employment_income = aggregate_employment
      self_employment_income = aggregate_self_employment
      pension_income = aggregate_pension_contributions
      gift_aid_income = aggregate_gift_aid_donations
      rental_income = aggregate_rental_property
      dividend_income = aggregate_dividends
      interest_income = aggregate_interest

      total_income = employment_income + self_employment_income + pension_income + gift_aid_income + rental_income + dividend_income + interest_income

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "income_aggregation",
        {
          employment: employment_income,
          self_employment: self_employment_income,
          pension_contributions: pension_income,
          gift_aid_donations: gift_aid_income,
          rental_property: rental_income,
          dividends: dividend_income,
          interest: interest_income
        },
        total_income,
        "Aggregated income from all sources (employment, self-employment, pension, gift aid, rental, dividends, interest)"
      )

      total_income
    end

    private

    def aggregate_employment
      IncomeSource.employment
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f
    end

    def aggregate_self_employment
      IncomeSource.self_employment
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f
    end

    def aggregate_pension_contributions
      IncomeSource.pension_contribution
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f
    end

    def aggregate_gift_aid_donations
      IncomeSource.gift_aid_donation
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f
    end

    def aggregate_rental_property
      IncomeSource.rental_property
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f
    end

    def aggregate_dividends
      IncomeSource.dividends
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f
    end

    def aggregate_interest
      IncomeSource.interest
        .where(tax_return: @tax_return)
        .sum(:amount_gross)
        .to_f
    end
  end
end
