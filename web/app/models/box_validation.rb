class BoxValidation < ApplicationRecord
  belongs_to :box_value
  belongs_to :validation_rule

  validates :box_value_id, uniqueness: { scope: :validation_rule_id }

  scope :valid, -> { where(is_valid: true) }
  scope :invalid, -> { where(is_valid: false) }
  scope :recent, -> { order(validated_at: :desc) }
  scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def error?
    validation_rule.severity == "error" && !is_valid
  end

  def warning?
    validation_rule.severity == "warning" && !is_valid
  end
end
