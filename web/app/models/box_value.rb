class BoxValue < ApplicationRecord
  belongs_to :tax_return
  belongs_to :box_definition
  has_many :evidence_box_values, dependent: :destroy
  has_many :evidences, through: :evidence_box_values

  validates :box_definition_id, uniqueness: { scope: :tax_return_id }

  encrypts :value_raw, :note
end
