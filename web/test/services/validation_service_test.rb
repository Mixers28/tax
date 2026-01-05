require "test_helper"

class ValidationServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    # Create form/page/box structure for testing
    @form = FormDefinition.create!(code: "SA102")
    @page = PageDefinition.create!(form_definition: @form, page_code: "TR1")
    @box = BoxDefinition.create!(
      page_definition: @page,
      box_code: "1",
      instance: 1,
      label: "Income"
    )
  end

  test "validate_all runs all validators" do
    service = ValidationService.new(@tax_return)
    results = service.validate_all

    assert results.is_a?(Hash)
    assert results.key?(:extraction_confidence)
  end

  test "validate_completeness identifies missing required fields" do
    # Create a completeness rule
    rule = ValidationRule.create!(
      rule_code: "sa102_complete",
      rule_type: "completeness",
      form_definition: @form,
      required_field_box_ids: [@box.id],
      severity: "error",
      description: "SA102 requires box 1"
    )

    service = ValidationService.new(@tax_return)
    results = service.validate_completeness

    assert results.any? { |r| !r[:is_valid] }
  end

  test "validate_completeness passes when all required fields present" do
    # Create completeness rule
    rule = ValidationRule.create!(
      rule_code: "sa102_complete",
      rule_type: "completeness",
      form_definition: @form,
      required_field_box_ids: [@box.id],
      severity: "error"
    )

    # Add box value
    @tax_return.box_values.create!(
      box_definition: @box,
      value_raw: "5000"
    )

    service = ValidationService.new(@tax_return)
    results = service.validate_completeness

    assert results.any? { |r| r[:is_valid] }
  end

  test "confidence validator flags low-confidence values" do
    # Create evidence with low confidence extraction
    evidence = @tax_return.evidences.create!
    evidence.file.attach(
      io: StringIO.new("PDF content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )

    box_value = @tax_return.box_values.create!(
      box_definition: @box,
      value_raw: "5000"
    )

    extraction_run = evidence.extraction_runs.create!(
      status: "completed",
      model: "gemma3:1b",
      started_at: Time.current,
      finished_at: Time.current,
      candidates: [{ confidence: 0.5 }]
    )

    service = ValidationService.new(@tax_return)
    results = service.validate_confidence

    assert results.any? { |r| !r[:is_valid] }
  end

  test "generate_report returns comprehensive validation summary" do
    # Create multiple rules
    ValidationRule.create!(
      rule_code: "test_rule_1",
      rule_type: "completeness",
      severity: "error"
    )
    ValidationRule.create!(
      rule_code: "test_rule_2",
      rule_type: "confidence",
      severity: "warning"
    )

    service = ValidationService.new(@tax_return)
    report = service.generate_report

    assert report.is_a?(Hash)
    assert report.key?(:test_rule_1)
    assert report[:test_rule_1][:rule_type] == "completeness"
  end
end
