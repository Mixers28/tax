class FxProvenance < ApplicationRecord
  belongs_to :provenanceable, polymorphic: true

  validates :original_currency, length: { maximum: 3 }, allow_nil: true
end
