class TaxLiability < ApplicationRecord
  belongs_to :tax_return

  validates :tax_return, presence: true, uniqueness: true
  validates :total_gross_income, :taxable_income, :total_income_tax, :total_ni, :total_tax_and_ni, numericality: true

  before_validation :calculate_totals

  # Get or create tax liability for a return
  def self.for_return(tax_return)
    find_or_create_by(tax_return: tax_return)
  end

  # Check if user owes tax (positive net_liability) or gets refund (negative)
  def owes_tax?
    net_liability > 0
  end

  def refund_due?
    net_liability < 0
  end

  def balanced?
    net_liability.abs < 0.01  # Account for rounding
  end

  # Summary for display
  def summary
    {
      total_gross_income: total_gross_income,
      personal_allowance_base: personal_allowance_base,
      blind_persons_allowance: blind_persons_allowance,
      personal_allowance_total: personal_allowance_total,
      pension_contributions_gross: pension_contributions_gross,
      pension_relief_at_source: pension_relief_at_source,
      gift_aid_donations_net: gift_aid_donations_net,
      gift_aid_gross_up: gift_aid_gross_up,
      gift_aid_extended_band: gift_aid_extended_band,
      rental_property_income: rental_property_income,
      furnished_property_relief: furnished_property_relief,
      self_employment_income: self_employment_income,
      hicbc_threshold_income: hicbc_threshold_income,
      hicbc_charge: hicbc_charge,
      # Phase 5d: Trading Allowance
      trading_income_gross: trading_income_gross,
      trading_allowance_amount: trading_allowance_amount,
      trading_income_net: trading_income_net,
      # Phase 5d: Marriage Allowance
      marriage_allowance_transfer_amount: marriage_allowance_transfer_amount,
      marriage_allowance_tax_reduction: marriage_allowance_tax_reduction,
      # Phase 5d: Married Couple's Allowance
      married_couples_allowance_amount: married_couples_allowance_amount,
      married_couples_allowance_relief: married_couples_allowance_relief,
      taxable_income: taxable_income,
      total_income_tax: total_income_tax,
      class_1_ni: class_1_ni,
      class_2_ni: class_2_ni,
      class_4_ni: class_4_ni,
      total_ni: total_ni,
      total_tax_and_ni: total_tax_and_ni,
      tax_paid_at_source: tax_paid_at_source,
      net_liability: net_liability,
      owes_tax: owes_tax?,
      refund_due: refund_due?
    }
  end

  private

  def calculate_totals
    # Sum up tax by band
    self.total_income_tax = (basic_rate_tax || 0) + (higher_rate_tax || 0) + (additional_rate_tax || 0)

    # Sum up NI
    self.total_ni = (class_1_ni || 0) + (class_2_ni || 0) + (class_4_ni || 0)

    # Total liability (includes HICBC charge if applicable)
    self.total_tax_and_ni = total_income_tax + total_ni + (hicbc_charge || 0)

    # Net payable/repayable
    self.net_liability = total_tax_and_ni - (tax_paid_at_source || 0)
  end
end
