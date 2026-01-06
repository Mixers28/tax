class AddPhase5dReliefsToTaxReturns < ActiveRecord::Migration[8.1]
  def change
    # Trading Allowance
    add_column :tax_returns, :uses_trading_allowance, :boolean, default: false, null: false

    # Marriage Allowance
    add_column :tax_returns, :claims_marriage_allowance, :boolean, default: false, null: false
    add_column :tax_returns, :marriage_allowance_role, :string, default: nil # "transferor" or "transferee"

    # Married Couple's Allowance
    add_column :tax_returns, :claims_married_couples_allowance, :boolean, default: false, null: false
    add_column :tax_returns, :spouse_dob, :date, default: nil # For MCA age eligibility
    add_column :tax_returns, :spouse_income, :decimal, precision: 12, scale: 2, default: 0
  end
end
