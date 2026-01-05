# frozen_string_literal: true

module TaxCalculations
  class IncomeAggregator
    def initialize(tax_return)
      @tax_return = tax_return
    end

    def calculate
      employment_income = aggregate_employment
      self_employment_income = aggregate_self_employment

      TaxCalculationBreakdown.record_step(
        @tax_return,
        "income_aggregation",
        {
          employment: employment_income,
          self_employment: self_employment_income
        },
        employment_income + self_employment_income,
        "Aggregated income from employment and self-employment sources"
      )

      employment_income + self_employment_income
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
  end
end
