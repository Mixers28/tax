class FieldValue < ApplicationRecord
  belongs_to :return_workspace
  belongs_to :template_field
  has_many :evidence_links, as: :linkable, dependent: :destroy
  has_one :fx_provenance, as: :provenanceable, dependent: :destroy

  validates :template_field_id, uniqueness: { scope: :return_workspace_id }

  encrypts :value_raw, :note
end
