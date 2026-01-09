class TemplateProfile < ApplicationRecord
  has_many :template_fields, dependent: :destroy
  has_many :return_workspaces, dependent: :destroy

  validates :name, presence: true
end
