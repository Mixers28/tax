class ExportEvidence < ApplicationRecord
  belongs_to :export
  belongs_to :evidence

  validates :export_id, uniqueness: { scope: :evidence_id }
end
