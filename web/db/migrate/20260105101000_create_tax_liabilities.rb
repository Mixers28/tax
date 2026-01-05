class CreateTaxLiabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_liabilities do |t|
      t.references :tax_return, null: false, foreign_key: true

      # Income summary
      t.decimal :total_gross_income, precision: 12, scale: 2, null: false, default: 0
      t.decimal :taxable_income, precision: 12, scale: 2, null: false, default: 0

      # Tax by band
      t.decimal :basic_rate_tax, precision: 12, scale: 2, null: false, default: 0
      t.decimal :higher_rate_tax, precision: 12, scale: 2, null: false, default: 0
      t.decimal :additional_rate_tax, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total_income_tax, precision: 12, scale: 2, null: false, default: 0

      # National Insurance
      t.decimal :class_1_ni, precision: 12, scale: 2, null: false, default: 0
      t.decimal :class_2_ni, precision: 12, scale: 2, null: false, default: 0
      t.decimal :class_4_ni, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total_ni, precision: 12, scale: 2, null: false, default: 0

      # Total liability
      t.decimal :total_tax_and_ni, precision: 12, scale: 2, null: false, default: 0
      t.decimal :tax_paid_at_source, precision: 12, scale: 2, null: false, default: 0
      t.decimal :net_liability, precision: 12, scale: 2, null: false, default: 0  # positive = owed, negative = repayment

      # Metadata
      t.jsonb :calculation_inputs, default: {}
      t.string :calculated_by, default: "user_input"
      t.datetime :calculated_at

      t.timestamps
    end

    add_index :tax_liabilities, :tax_return_id, unique: true
  end
end
