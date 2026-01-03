class CreateTaxYears < ActiveRecord::Migration[8.1]
  def change
    create_table :tax_years do |t|
      t.string :label, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end

    add_index :tax_years, :label, unique: true
  end
end
