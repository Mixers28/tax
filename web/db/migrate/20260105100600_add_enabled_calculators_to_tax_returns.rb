class AddEnabledCalculatorsToTaxReturns < ActiveRecord::Migration[8.0]
  def change
    add_column :tax_returns, :enabled_calculators, :string, default: "gift_aid,hicbc"
    add_index :tax_returns, :enabled_calculators
  end
end
