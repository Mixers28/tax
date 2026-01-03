class CreatePageDefinitions < ActiveRecord::Migration[8.1]
  def change
    create_table :page_definitions do |t|
      t.references :form_definition, null: false, foreign_key: true
      t.string :page_code, null: false
      t.string :title

      t.timestamps
    end

    add_index :page_definitions, [:form_definition_id, :page_code], unique: true
  end
end
