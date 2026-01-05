class CreateValidationRules < ActiveRecord::Migration[8.1]
  def change
    create_table :validation_rules do |t|
      t.string :rule_code, null: false
      t.string :rule_type, null: false # completeness, cross_field, confidence, business_logic
      t.references :form_definition, null: true, foreign_key: true
      t.json :required_field_box_ids
      t.json :condition
      t.string :severity, default: "warning" # error, warning, info
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :validation_rules, :rule_code, unique: true
    add_index :validation_rules, [:form_definition_id, :rule_type]
  end
end
