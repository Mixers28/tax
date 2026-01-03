class AdjustBoxValuesForEncryption < ActiveRecord::Migration[8.1]
  def change
    change_column :box_values, :value_raw, :text
  end
end
