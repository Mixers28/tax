class TaxYear < ApplicationRecord
  has_many :tax_returns, dependent: :destroy

  validates :label, :start_date, :end_date, presence: true
end
