class AddCurrencyToIncomeSources < ActiveRecord::Migration[8.1]
  def change
    add_column :income_sources, :currency, :string, default: 'GBP'
    add_column :income_sources, :exchange_rate, :decimal, precision: 10, scale: 6, default: 1.0
  end
end
