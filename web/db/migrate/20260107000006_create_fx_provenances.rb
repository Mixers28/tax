class CreateFxProvenances < ActiveRecord::Migration[8.1]
  def change
    create_table :fx_provenances, if_not_exists: true do |t|
      t.references :provenanceable, null: false, polymorphic: true, index: false
      t.decimal :original_amount, precision: 12, scale: 2
      t.string :original_currency, limit: 3
      t.decimal :gbp_amount, precision: 12, scale: 2
      t.decimal :exchange_rate, precision: 12, scale: 6
      t.string :rate_method
      t.string :rate_period
      t.string :rate_source
      t.text :note

      t.timestamps
    end

    add_index :fx_provenances,
      [:provenanceable_type, :provenanceable_id],
      name: "index_fx_provenances_on_provenanceable",
      if_not_exists: true
  end
end
