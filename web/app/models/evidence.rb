class Evidence < ApplicationRecord
  belongs_to :tax_return
  has_one_attached :file
  has_many :evidence_box_values, dependent: :destroy
  has_many :box_values, through: :evidence_box_values

  before_validation :sync_file_metadata, if: -> { file.attached? }

  validates :filename, presence: true
  validate :file_attached

  encrypts :filename, :mime, :sha256

  private

  def sync_file_metadata
    self.filename = file.filename.to_s
    self.mime = file.content_type
  end

  def file_attached
    errors.add(:file, "must be attached") unless file.attached?
  end
end
