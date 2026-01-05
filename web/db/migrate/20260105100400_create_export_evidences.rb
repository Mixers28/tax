class CreateExportEvidences < ActiveRecord::Migration[8.1]
  def change
    create_table :export_evidences do |t|
      t.references :export, null: false, foreign_key: true
      t.references :evidence, null: false, foreign_key: true
      t.json :referenced_in_values # Which box values reference this evidence

      t.timestamps
    end

    add_index :export_evidences, [:export_id, :evidence_id], unique: true
  end
end
