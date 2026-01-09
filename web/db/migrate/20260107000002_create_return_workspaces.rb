class CreateReturnWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :return_workspaces, if_not_exists: true do |t|
      t.references :tax_return, null: false, foreign_key: true, index: false
      t.references :template_profile, null: false, foreign_key: true

      t.timestamps
    end

    add_index :return_workspaces, :tax_return_id,
      unique: true,
      name: "index_return_workspaces_on_tax_return_id_unique",
      if_not_exists: true
  end
end
