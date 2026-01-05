require "test_helper"

class ExportServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    # Create form structure
    @form = FormDefinition.create!(code: "SA100")
    @page = PageDefinition.create!(form_definition: @form, page_code: "1")
    @box = BoxDefinition.create!(
      page_definition: @page,
      box_code: "1",
      instance: 1,
      label: "Test Box"
    )

    # Add box value
    @tax_return.box_values.create!(box_definition: @box, value_raw: "5000")

    # Add evidence
    @evidence = @tax_return.evidences.create!
    @evidence.file.attach(
      io: StringIO.new("PDF content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
  end

  test "generate creates export record" do
    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    assert export.persisted?
    assert_equal @tax_return.id, export.tax_return_id
    assert_equal @user.id, export.user_id
  end

  test "generate captures validation state" do
    # Create a validation rule first
    ValidationRule.create!(
      rule_code: "test_rule",
      rule_type: "completeness",
      severity: "error"
    )

    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    assert export.validation_state.present?
    assert export.validation_state.is_a?(Hash)
  end

  test "generate captures box values snapshot" do
    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    assert export.export_snapshot.present?
    assert export.export_snapshot.is_a?(Array)
    assert export.export_snapshot.any? { |s| s["box_code"] == "1" }
  end

  test "generate links evidence" do
    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    export_evidences = ExportEvidence.where(export: export)
    assert export_evidences.any?
    assert export_evidences.first.evidence_id == @evidence.id
  end

  test "generate creates file hash" do
    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    assert export.file_hash.present?
    assert export.file_hash.length == 64  # SHA256 hex is 64 chars
  end

  test "format pdf only creates pdf export" do
    service = ExportService.new(@tax_return, @user, "pdf")
    export = service.generate!

    assert export.pdf?
    assert !export.json?
  end

  test "format json only creates json export" do
    service = ExportService.new(@tax_return, @user, "json")
    export = service.generate!

    assert !export.pdf?
    assert export.json?
  end

  test "format both creates both exports" do
    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    assert export.pdf?
    assert export.json?
  end

  test "export sets exported_at timestamp" do
    before_time = Time.current
    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    assert export.exported_at >= before_time
    assert export.exported_at <= Time.current
  end

  test "multiple exports for same tax return" do
    service1 = ExportService.new(@tax_return, @user, "both")
    export1 = service1.generate!

    service2 = ExportService.new(@tax_return, @user, "both")
    export2 = service2.generate!

    assert export1.id != export2.id
    assert @tax_return.exports.count == 2
  end

  test "export captures calculations if present" do
    # This would require calculator setup
    service = ExportService.new(@tax_return, @user, "both")
    export = service.generate!

    assert export.calculation_results.present?
  end
end
