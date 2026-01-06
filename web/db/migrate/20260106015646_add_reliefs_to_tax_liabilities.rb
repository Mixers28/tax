class AddReliefsToTaxLiabilities < ActiveRecord::Migration[8.1]
  def change
    # Pension tracking
    add_column :tax_liabilities, :pension_contributions_gross, :decimal, precision: 12, scale: 2, default: 0
    add_column :tax_liabilities, :pension_relief_at_source, :decimal, precision: 12, scale: 2, default: 0

    # Gift Aid tracking
    add_column :tax_liabilities, :gift_aid_donations_net, :decimal, precision: 12, scale: 2, default: 0
    add_column :tax_liabilities, :gift_aid_gross_up, :decimal, precision: 12, scale: 2, default: 0
    add_column :tax_liabilities, :gift_aid_extended_band, :decimal, precision: 12, scale: 2, default: 0

    # Blind Person's Allowance
    add_column :tax_liabilities, :blind_persons_allowance, :decimal, precision: 12, scale: 2, default: 0
    add_column :tax_liabilities, :personal_allowance_base, :decimal, precision: 12, scale: 2, default: 0
    add_column :tax_liabilities, :personal_allowance_total, :decimal, precision: 12, scale: 2, default: 0
  end
end
