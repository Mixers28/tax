class CreateTaxReturns < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_returns do |t|
      t.references :tax_year, null: false, foreign_key: true
      t.string :status, null: false, default: "draft"

      t.timestamps
    end
  end
end
