class ReturnWorkspace < ApplicationRecord
  belongs_to :tax_return
  belongs_to :template_profile
  has_many :field_values, dependent: :destroy

  validates :tax_return_id, uniqueness: true
end
