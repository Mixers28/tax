class CreateFormDefinitions < ActiveRecord::Migration[8.1]
  def change
    create_table :form_definitions do |t|
      t.string :code, null: false
      t.integer :year, null: false
      t.json :version_meta

      t.timestamps
    end

    add_index :form_definitions, [:code, :year], unique: true
  end
end
