class TaxBand < ApplicationRecord
  validates :tax_year, presence: true, uniqueness: true
  validates :pa_amount, :basic_rate_limit, :higher_rate_limit, presence: true
  validates :basic_rate_percentage, :higher_rate_percentage, :additional_rate_percentage, presence: true
  validates :ni_lower_threshold, :ni_upper_threshold, presence: true
  validates :ni_basic_percentage, :ni_higher_percentage, presence: true

  # 2024-25 thresholds (default)
  def self.for_tax_year(year = 2024)
    find_by(tax_year: year) || create_default_2024_25
  end

  private

  def self.create_default_2024_25
    create!(
      tax_year: 2024,
      pa_amount: 12_570.00,
      basic_rate_limit: 50_270.00,
      higher_rate_limit: 125_140.00,
      basic_rate_percentage: 20.00,
      higher_rate_percentage: 40.00,
      additional_rate_percentage: 45.00,
      ni_lower_threshold: 12_570.00,
      ni_upper_threshold: 50_270.00,
      ni_basic_percentage: 8.00,
      ni_higher_percentage: 2.00
    )
  end
end
