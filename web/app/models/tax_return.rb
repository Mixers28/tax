class TaxReturn < ApplicationRecord
  AVAILABLE_CALCULATORS = {
    ftcr: "Furnished Temporary Accommodation Relief",
    gift_aid: "Gift Aid",
    hicbc: "High Income Child Benefit Charge"
  }.freeze

  belongs_to :user
  belongs_to :tax_year
  has_many :box_values, dependent: :destroy
  has_many :evidences, dependent: :destroy
  has_many :exports, dependent: :destroy
  has_many :tax_calculations, dependent: :destroy

  validates :status, presence: true

  def calculator_enabled?(calculator_code)
    enabled_calculators_list.include?(calculator_code.to_s)
  end

  def enabled_calculators_list
    (enabled_calculators || "").split(",").map(&:strip).compact
  end

  def toggle_calculator(calculator_code, enabled)
    current = enabled_calculators_list
    code = calculator_code.to_s

    if enabled && !current.include?(code)
      current << code
    elsif !enabled && current.include?(code)
      current.delete(code)
    end

    update!(enabled_calculators: current.join(","))
  end

  def enable_calculator(calculator_code)
    toggle_calculator(calculator_code, true)
  end

  def disable_calculator(calculator_code)
    toggle_calculator(calculator_code, false)
  end
end
