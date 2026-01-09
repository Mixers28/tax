class CreateEvidenceLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :evidence_links do |t|
      t.references :evidence, null: false, foreign_key: true
      t.references :linkable, null: false, polymorphic: true
      t.text :note

      t.timestamps
    end

    add_index :evidence_links, [:evidence_id, :linkable_type, :linkable_id], unique: true, name: "index_evidence_links_on_evidence_and_linkable"
  end
end
