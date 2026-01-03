class CreateBoxDefinitions < ActiveRecord::Migration[8.1]
  def change
    create_table :box_definitions do |t|
      t.references :page_definition, null: false, foreign_key: true
      t.string :box_code, null: false
      t.integer :instance, null: false, default: 1
      t.string :hmrc_label, null: false
      t.string :data_type, null: false, default: "text"
      t.json :constraints
      t.string :required_rule

      t.timestamps
    end

    add_index :box_definitions, [:page_definition_id, :box_code, :instance], unique: true, name: "index_box_defs_on_page_and_code_and_instance"
  end
end
