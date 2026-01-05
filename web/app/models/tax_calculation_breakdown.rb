class TaxCalculationBreakdown < ApplicationRecord
  belongs_to :tax_return

  validates :tax_return, :step_key, presence: true

  scope :ordered, -> { order(:sequence_order) }

  # Record a calculation step for transparency and audit
  def self.record_step(tax_return, step_key, inputs = {}, result = nil, explanation = "")
    sequence = where(tax_return: tax_return).count + 1
    create!(
      tax_return: tax_return,
      step_key: step_key,
      inputs: inputs,
      result: result,
      explanation: explanation,
      sequence_order: sequence
    )
  end

  # Get all steps for a tax return in order
  def self.for_return(tax_return)
    where(tax_return: tax_return).ordered
  end

  # Get a specific step
  def self.find_step(tax_return, step_key)
    where(tax_return: tax_return, step_key: step_key).first
  end
end
