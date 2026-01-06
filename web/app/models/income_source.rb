class IncomeSource < ApplicationRecord
  belongs_to :tax_return

  enum :source_type, {
    employment: 0,
    self_employment: 1,
    dividends: 2,
    interest: 3,
    pension: 4,
    other: 5,
    pension_contribution: 6,
    gift_aid_donation: 7
  }

  validates :tax_return, :source_type, :amount_gross, presence: true
  validates :amount_gross, :amount_tax_taken, numericality: { greater_than_or_equal_to: 0 }

  scope :employment, -> { where(source_type: :employment) }
  scope :self_employment, -> { where(source_type: :self_employment) }
  scope :dividends, -> { where(source_type: :dividends) }
  scope :interest, -> { where(source_type: :interest) }
  scope :eligible_for_pa, -> { where(is_eligible_for_pa: true) }
  scope :eligible_for_relief, -> { where(is_eligible_for_relief: true) }
  scope :pension_contributions, -> { where(source_type: :pension_contribution) }
  scope :gift_aid_donations, -> { where(source_type: :gift_aid_donation) }

  # Total gross income from all sources
  def self.total_gross(tax_return)
    where(tax_return: tax_return).sum(:amount_gross)
  end

  # Total tax already taken at source
  def self.total_tax_taken(tax_return)
    where(tax_return: tax_return).sum(:amount_tax_taken)
  end
end
