class AddIsBlindPersonToTaxReturns < ActiveRecord::Migration[8.1]
  def change
    add_column :tax_returns, :is_blind_person, :boolean, default: false, null: false
    add_index :tax_returns, :is_blind_person
  end
end
