class BoxValue < ApplicationRecord
  belongs_to :tax_return
  belongs_to :box_definition
  has_many :evidence_box_values, dependent: :destroy
  has_many :evidences, through: :evidence_box_values
  has_many :box_validations, dependent: :destroy
  has_many :validation_rules, through: :box_validations

  validates :box_definition_id, uniqueness: { scope: :tax_return_id }

  encrypts :value_raw, :note

  def validation_status
    validations = box_validations.includes(:validation_rule)
    errors = validations.count { |v| !v.is_valid && v.validation_rule.severity == "error" }
    warnings = validations.count { |v| !v.is_valid && v.validation_rule.severity == "warning" }

    if errors > 0
      :invalid
    elsif warnings > 0
      :warning
    else
      :valid
    end
  end

  def validation_summary
    validations = box_validations.includes(:validation_rule).active
    {
      total: validations.count,
      valid: validations.count { |v| v.is_valid },
      errors: validations.where(validation_rules: { severity: "error" }, is_valid: false).count,
      warnings: validations.where(validation_rules: { severity: "warning" }, is_valid: false).count
    }
  end
end
