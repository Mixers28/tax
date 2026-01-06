class AddBlindPersonsAllowanceToTaxBands < ActiveRecord::Migration[8.1]
  def change
    add_column :tax_bands, :blind_persons_allowance, :decimal, precision: 12, scale: 2, default: 0
  end
end
