class ValidationRule < ApplicationRecord
  belongs_to :form_definition, optional: true
  has_many :box_validations, dependent: :destroy

  validates :rule_code, presence: true, uniqueness: true
  validates :rule_type, presence: true, inclusion: { in: %w(completeness cross_field confidence business_logic) }
  validates :severity, presence: true, inclusion: { in: %w(error warning info) }

  RULE_TYPES = {
    completeness: "completeness",
    cross_field: "cross_field",
    confidence: "confidence",
    business_logic: "business_logic"
  }.freeze

  SEVERITIES = {
    error: "error",
    warning: "warning",
    info: "info"
  }.freeze

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(rule_type: type) }
  scope :by_form, ->(form_id) { where(form_definition_id: form_id) }
end
