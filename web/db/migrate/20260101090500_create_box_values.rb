class CreateBoxValues < ActiveRecord::Migration[8.1]
  def change
    create_table :box_values do |t|
      t.references :tax_return, null: false, foreign_key: true
      t.references :box_definition, null: false, foreign_key: true
      t.string :value_raw
      t.integer :value_gbp
      t.string :currency
      t.integer :scenario_id
      t.text :note

      t.timestamps
    end

    add_index :box_values, :scenario_id
    add_index :box_values, [:tax_return_id, :box_definition_id], unique: true
  end
end
