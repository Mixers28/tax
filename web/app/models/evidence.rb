require "digest"

class Evidence < ApplicationRecord
  EVIDENCE_TYPES = {
    blank_form: "Blank Tax Form",
    supporting_document: "Supporting Document"
  }.freeze

  belongs_to :tax_return
  has_one_attached :file
  has_many :extraction_runs, dependent: :destroy
  has_many :evidence_box_values, dependent: :destroy
  has_many :box_values, through: :evidence_box_values
  has_many :evidence_links, dependent: :destroy
  has_many :export_evidences, dependent: :destroy
  has_many :exports, through: :export_evidences

  before_validation :sync_file_metadata, if: -> { file.attached? }
  after_commit :sync_file_sha256, on: [:create, :update], if: -> { file.attached? && sha256.blank? }

  validates :filename, presence: true
  validates :evidence_type, presence: true, inclusion: { in: EVIDENCE_TYPES.keys.map(&:to_s) }
  validate :file_attached

  encrypts :filename, :mime, :sha256

  private

  def sync_file_metadata
    self.filename = file.filename.to_s
    self.mime = file.content_type
  end

  def sync_file_sha256
    digest = Digest::SHA256.hexdigest(file.download)
    update!(sha256: digest)
  end

  def file_attached
    errors.add(:file, "must be attached") unless file.attached?
  end
end
