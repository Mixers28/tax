class CreateTaxCalculationBreakdowns < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_calculation_breakdowns do |t|
      t.references :tax_return, null: false, foreign_key: true
      t.string :step_key, null: false  # e.g., "employment_aggregation", "pa_relief", "basic_rate_tax"
      t.jsonb :inputs, default: {}
      t.decimal :result, precision: 12, scale: 2
      t.text :explanation
      t.integer :sequence_order

      t.timestamps
    end

    add_index :tax_calculation_breakdowns, :tax_return_id
    add_index :tax_calculation_breakdowns, [:tax_return_id, :step_key]
  end
end
