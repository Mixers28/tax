class AdjustEvidenceStorage < ActiveRecord::Migration[8.1]
  def change
    remove_column :evidences, :encrypted_blob, :binary
    change_column :evidences, :filename, :text, null: false
    change_column :evidences, :mime, :text
    change_column :evidences, :sha256, :text
  end
end
