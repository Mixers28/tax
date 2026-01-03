class TaxReturn < ApplicationRecord
  belongs_to :tax_year
  has_many :box_values, dependent: :destroy
  has_many :evidences, dependent: :destroy

  validates :status, presence: true
end
