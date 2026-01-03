class FormDefinition < ApplicationRecord
  has_many :page_definitions, dependent: :destroy

  validates :code, :year, presence: true
end
