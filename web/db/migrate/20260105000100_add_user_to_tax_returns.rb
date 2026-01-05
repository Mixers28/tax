class AddUserToTaxReturns < ActiveRecord::Migration[8.1]
  def change
    # First add the column as nullable to handle existing data
    add_reference :tax_returns, :user, null: true, foreign_key: true
  end
end
