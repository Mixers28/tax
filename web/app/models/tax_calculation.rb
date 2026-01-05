class TaxCalculation < ApplicationRecord
  belongs_to :tax_return
  belongs_to :box_definition, optional: true

  validates :calculation_type, presence: true, inclusion: { in: %w(ftcr gift_aid hicbc) }

  CALCULATION_TYPES = {
    ftcr: "ftcr",
    gift_aid: "gift_aid",
    hicbc: "hicbc"
  }.freeze

  scope :by_type, ->(type) { where(calculation_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  def calculation_name
    case calculation_type
    when "ftcr"
      "Furnished Temporary Accommodation Relief"
    when "gift_aid"
      "Gift Aid"
    when "hicbc"
      "High Income Child Benefit Charge"
    else
      calculation_type
    end
  end

  def formatted_result
    "£#{result_value_gbp.round(2)}" if result_value_gbp
  end
end
