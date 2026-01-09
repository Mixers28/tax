class RemoveReturnWorkspacesTaxReturnIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :return_workspaces, name: "index_return_workspaces_on_tax_return_id", if_exists: true
  end
end
