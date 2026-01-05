class CreateIncomeSources < ActiveRecord::Migration[8.1]
  def change
    create_table :income_sources do |t|
      t.references :tax_return, null: false, foreign_key: true
      t.integer :source_type, null: false, default: 0  # enum: employment, self_employment, dividends, interest, pension, other
      t.decimal :amount_gross, precision: 12, scale: 2, null: false
      t.decimal :amount_tax_taken, precision: 12, scale: 2, null: false, default: 0
      t.string :description
      t.boolean :is_eligible_for_pa, default: true
      t.boolean :is_eligible_for_relief, default: false

      t.timestamps
    end

    add_index :income_sources, :source_type
  end
end
