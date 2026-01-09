class CreateFieldValues < ActiveRecord::Migration[8.1]
  def change
    create_table :field_values do |t|
      t.references :return_workspace, null: false, foreign_key: true
      t.references :template_field, null: false, foreign_key: true
      t.text :value_raw
      t.text :note
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :field_values, [:return_workspace_id, :template_field_id], unique: true, name: "index_field_values_on_workspace_and_field"
  end
end
