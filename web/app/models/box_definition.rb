class BoxDefinition < ApplicationRecord
  belongs_to :page_definition
  has_many :box_values, dependent: :destroy

  validates :box_code, :hmrc_label, :data_type, presence: true
  validates :instance, numericality: { only_integer: true, greater_than: 0 }
end
