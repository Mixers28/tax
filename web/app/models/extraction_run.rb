class ExtractionRun < ApplicationRecord
  belongs_to :evidence

  validates :status, :model, :started_at, presence: true
end
