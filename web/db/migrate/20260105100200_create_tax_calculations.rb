class CreateTaxCalculations < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_calculations do |t|
      t.references :tax_return, null: false, foreign_key: true
      t.string :calculation_type, null: false # ftcr, gift_aid, hicbc
      t.references :box_definition, null: true, foreign_key: true # Output box
      t.json :input_box_ids
      t.decimal :result_value_gbp, precision: 15, scale: 2
      t.decimal :confidence_score, precision: 3, scale: 2, default: 1.0
      t.json :calculation_steps
      t.json :input_values

      t.timestamps
    end

    add_index :tax_calculations, [:tax_return_id, :calculation_type]
  end
end
