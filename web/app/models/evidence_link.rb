class EvidenceLink < ApplicationRecord
  belongs_to :evidence
  belongs_to :linkable, polymorphic: true

  validates :evidence_id, uniqueness: { scope: [:linkable_type, :linkable_id] }
end
