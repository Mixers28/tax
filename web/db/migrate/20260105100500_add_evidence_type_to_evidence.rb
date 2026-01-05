class AddEvidenceTypeToEvidence < ActiveRecord::Migration[8.0]
  def change
    add_column :evidences, :evidence_type, :string, default: "supporting_document"
    add_index :evidences, :evidence_type
  end
end
