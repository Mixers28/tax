class Export < ApplicationRecord
  belongs_to :tax_return
  belongs_to :user
  has_many :export_evidences, dependent: :destroy
  has_many :evidences, through: :export_evidences

  validates :format, presence: true, inclusion: { in: %w(pdf json both) }

  scope :recent, -> { order(exported_at: :desc) }
  scope :by_format, ->(format) { where(format: format) }

  FORMATS = {
    pdf: "pdf",
    json: "json",
    both: "both"
  }.freeze

  def pdf?
    format.in?(["pdf", "both"])
  end

  def json?
    format.in?(["json", "both"])
  end

  def ready_for_download?
    pdf? && file_path.present? || json? && json_path.present?
  end

  def validation_summary
    return {} unless validation_state.present?

    # validation_state is a hash from ValidationService.generate_report
    # with keys: total, passed, failed, errors, warnings, info
    {
      total: validation_state["total"] || 0,
      errors: (validation_state["errors"] || []).length,
      warnings: (validation_state["warnings"] || []).length,
      valid: validation_state["passed"] || 0
    }
  end
end
