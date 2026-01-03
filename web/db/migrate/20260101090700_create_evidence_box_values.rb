class CreateEvidenceBoxValues < ActiveRecord::Migration[8.1]
  def change
    create_table :evidence_box_values do |t|
      t.references :evidence, null: false, foreign_key: true
      t.references :box_value, null: false, foreign_key: true

      t.timestamps
    end

    add_index :evidence_box_values, [:evidence_id, :box_value_id], unique: true
  end
end
