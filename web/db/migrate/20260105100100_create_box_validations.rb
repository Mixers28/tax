class CreateBoxValidations < ActiveRecord::Migration[8.1]
  def change
    create_table :box_validations do |t|
      t.references :box_value, null: false, foreign_key: true
      t.references :validation_rule, null: false, foreign_key: true
      t.boolean :is_valid, default: false
      t.text :error_message
      t.text :warning_message
      t.datetime :validated_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :box_validations, [:box_value_id, :validation_rule_id], unique: true
    add_index :box_validations, :validated_at
  end
end
