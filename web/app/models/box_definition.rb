class BoxDefinition < ApplicationRecord
  belongs_to :page_definition
  has_many :box_values, dependent: :destroy

  validates :box_code, :hmrc_label, :data_type, presence: true
  validates :instance, numericality: { only_integer: true, greater_than: 0 }

  def display_label
    form_code = page_definition&.form_definition&.code
    page_code = page_definition&.page_code
    parts = [form_code, page_code, "Box #{box_code}", hmrc_label].compact
    parts.join(" - ")
  end
end
