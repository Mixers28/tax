class CreateTaxBands < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_bands do |t|
      t.integer :tax_year, null: false
      t.decimal :pa_amount, precision: 12, scale: 2, null: false
      t.decimal :basic_rate_limit, precision: 12, scale: 2, null: false
      t.decimal :higher_rate_limit, precision: 12, scale: 2, null: false
      t.decimal :basic_rate_percentage, precision: 5, scale: 2, null: false
      t.decimal :higher_rate_percentage, precision: 5, scale: 2, null: false
      t.decimal :additional_rate_percentage, precision: 5, scale: 2, null: false
      t.decimal :ni_lower_threshold, precision: 12, scale: 2, null: false
      t.decimal :ni_upper_threshold, precision: 12, scale: 2, null: false
      t.decimal :ni_basic_percentage, precision: 5, scale: 2, null: false
      t.decimal :ni_higher_percentage, precision: 5, scale: 2, null: false

      t.timestamps
    end

    add_index :tax_bands, :tax_year, unique: true
  end
end
