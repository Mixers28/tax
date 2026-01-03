class PageDefinition < ApplicationRecord
  belongs_to :form_definition
  has_many :box_definitions, dependent: :destroy

  validates :page_code, presence: true
end
