require "test_helper"

class EvidenceTest < ActiveSupport::TestCase
  test "attaches file and syncs metadata" do
    tax_year = TaxYear.create!(label: "2024-25", start_date: Date.new(2024, 4, 6), end_date: Date.new(2025, 4, 5))
    tax_return = TaxReturn.create!(tax_year: tax_year, status: "draft")

    evidence = Evidence.new(tax_return: tax_return)
    evidence.file.attach(
      io: file_fixture("sample.txt").open,
      filename: "sample.txt",
      content_type: "text/plain"
    )

    assert evidence.save!
    assert_equal "sample.txt", evidence.filename
    assert_equal "text/plain", evidence.mime
    assert_equal Digest::SHA256.hexdigest(file_fixture("sample.txt").read), evidence.reload.sha256
  end

  test "requires a file attachment" do
    tax_year = TaxYear.create!(label: "2024-26", start_date: Date.new(2024, 4, 6), end_date: Date.new(2025, 4, 5))
    tax_return = TaxReturn.create!(tax_year: tax_year, status: "draft")

    evidence = Evidence.new(tax_return: tax_return)

    assert_not evidence.valid?
    assert_includes evidence.errors[:file], "must be attached"
  end
end
