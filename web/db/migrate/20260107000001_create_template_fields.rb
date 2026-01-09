class CreateTemplateFields < ActiveRecord::Migration[8.1]
  def change
    create_table :template_fields do |t|
      t.references :template_profile, null: false, foreign_key: true
      t.references :box_definition, foreign_key: true
      t.string :label
      t.string :data_type, null: false, default: "text"
      t.boolean :required, null: false, default: true
      t.integer :position

      t.timestamps
    end

    add_index :template_fields, [:template_profile_id, :position]
    add_index :template_fields, [:template_profile_id, :box_definition_id], unique: true, name: "index_template_fields_on_profile_and_box_def"
  end
end
