class AddFtcrHicbcNiToTaxLiabilities < ActiveRecord::Migration[8.1]
  def change
    # Furnished Property Relief (FTCR)
    add_column :tax_liabilities, :rental_property_income, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :rental_property_income)
    add_column :tax_liabilities, :furnished_property_relief, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :furnished_property_relief)

    # High Income Child Benefit Charge (HICBC)
    add_column :tax_liabilities, :hicbc_threshold_income, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :hicbc_threshold_income)
    add_column :tax_liabilities, :hicbc_charge, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :hicbc_charge)

    # Self-employment income
    add_column :tax_liabilities, :self_employment_income, :decimal, precision: 12, scale: 2, default: 0 unless column_exists?(:tax_liabilities, :self_employment_income)
  end
end
