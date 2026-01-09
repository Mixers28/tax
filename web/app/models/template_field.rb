class TemplateField < ApplicationRecord
  belongs_to :template_profile
  belongs_to :box_definition, optional: true
  has_many :field_values, dependent: :destroy

  validates :data_type, presence: true
  validates :label, presence: true, if: -> { box_definition_id.nil? }
  validates :box_definition_id, uniqueness: { scope: :template_profile_id }, allow_nil: true
end
