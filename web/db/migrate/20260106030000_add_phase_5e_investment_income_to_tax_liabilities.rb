# frozen_string_literal: true

class AddPhase5eInvestmentIncomeToTaxLiabilities < ActiveRecord::Migration[8.1]
  def change
    # Dividend income tracking
    add_column :tax_liabilities, :dividend_income_gross, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :dividend_income_gross)
    add_column :tax_liabilities, :dividend_allowance_amount, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :dividend_allowance_amount)
    add_column :tax_liabilities, :dividend_income_taxable, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :dividend_income_taxable)

    # Savings interest tracking
    add_column :tax_liabilities, :savings_interest_gross, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :savings_interest_gross)
    add_column :tax_liabilities, :savings_allowance_amount, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :savings_allowance_amount)
    add_column :tax_liabilities, :savings_interest_taxable, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :savings_interest_taxable)

    # Investment income tax calculations
    add_column :tax_liabilities, :dividend_basic_rate_tax, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :dividend_basic_rate_tax)
    add_column :tax_liabilities, :dividend_higher_rate_tax, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :dividend_higher_rate_tax)
    add_column :tax_liabilities, :dividend_additional_rate_tax, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :dividend_additional_rate_tax)
    add_column :tax_liabilities, :total_dividend_tax, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :total_dividend_tax)

    add_column :tax_liabilities, :savings_interest_tax, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :savings_interest_tax)
  end
end
