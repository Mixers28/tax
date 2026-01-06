class AddPhase5dReliefsToTaxLiabilities < ActiveRecord::Migration[8.1]
  def change
    # Trading Allowance
    add_column :tax_liabilities, :trading_income_gross, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :trading_income_gross)
    add_column :tax_liabilities, :trading_allowance_amount, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :trading_allowance_amount)
    add_column :tax_liabilities, :trading_income_net, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :trading_income_net)

    # Marriage Allowance
    add_column :tax_liabilities, :marriage_allowance_transfer_amount, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :marriage_allowance_transfer_amount)
    add_column :tax_liabilities, :marriage_allowance_tax_reduction, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :marriage_allowance_tax_reduction)

    # Married Couple's Allowance
    add_column :tax_liabilities, :married_couples_allowance_amount, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :married_couples_allowance_amount)
    add_column :tax_liabilities, :married_couples_allowance_relief, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :married_couples_allowance_relief)
  end
end
