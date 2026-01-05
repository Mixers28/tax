require "test_helper"

class ValidationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @other_user = User.create!(email: "other@example.com", password: "password123")

    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )

    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")
    @other_tax_return = @other_user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    # Create validation rule
    @form = FormDefinition.create!(code: "SA100")
    @page = PageDefinition.create!(form_definition: @form, page_code: "1")
    @box = BoxDefinition.create!(
      page_definition: @page,
      box_code: "1",
      instance: 1,
      label: "Test"
    )

    @validation_rule = ValidationRule.create!(
      rule_code: "test_completeness",
      rule_type: "completeness",
      form_definition: @form,
      required_field_box_ids: [@box.id],
      severity: "error",
      description: "Test rule"
    )

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: "password123" }
  end

  test "user can view validations" do
    get "/tax_returns/#{@tax_return.id}/validations"
    assert_response :success
  end

  test "user cannot view other user's validations" do
    get "/tax_returns/#{@other_tax_return.id}/validations"
    assert_response :redirect
  end

  test "validations index shows box validations" do
    # Create a box value with validations
    box_value = @tax_return.box_values.create!(box_definition: @box, value_raw: "5000")
    box_validation = box_value.box_validations.create!(
      validation_rule: @validation_rule,
      is_valid: true,
      validated_at: Time.current
    )

    get "/tax_returns/#{@tax_return.id}/validations"
    assert_response :success
  end

  test "run_validation endpoint runs all validators" do
    stub_validation_service

    post "/tax_returns/#{@tax_return.id}/validations/run_validation"

    assert_response :success
    response_json = JSON.parse(response.body)
    assert response_json["success"]
    assert response_json["results"].is_a?(Hash)
    assert response_json["summary"].is_a?(Hash)
  end

  test "run_validation summary includes counts" do
    stub_validation_service

    post "/tax_returns/#{@tax_return.id}/validations/run_validation"

    response_json = JSON.parse(response.body)
    summary = response_json["summary"]

    assert summary.key?("total")
    assert summary.key?("valid")
    assert summary.key?("errors")
    assert summary.key?("warnings")
    assert summary.key?("status")
  end

  test "user cannot run validation for other user's return" do
    post "/tax_returns/#{@other_tax_return.id}/validations/run_validation"
    assert_response :redirect
  end

  test "validation status shows passing when no errors" do
    stub_validation_service_passing

    post "/tax_returns/#{@tax_return.id}/validations/run_validation"

    response_json = JSON.parse(response.body)
    assert_equal "passing", response_json["summary"]["status"]
  end

  test "validation status shows failing when errors exist" do
    stub_validation_service_failing

    post "/tax_returns/#{@tax_return.id}/validations/run_validation"

    response_json = JSON.parse(response.body)
    assert_equal "failing", response_json["summary"]["status"]
  end

  private

  def stub_validation_service
    service_double = double("ValidationService")
    allow(ValidationService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:validate_all).and_return({
      "rule_1" => { is_valid: true, severity: "error" },
      "rule_2" => { is_valid: false, severity: "warning" }
    })
  end

  def stub_validation_service_passing
    service_double = double("ValidationService")
    allow(ValidationService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:validate_all).and_return({
      "rule_1" => { is_valid: true, severity: "error" },
      "rule_2" => { is_valid: true, severity: "warning" }
    })
  end

  def stub_validation_service_failing
    service_double = double("ValidationService")
    allow(ValidationService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:validate_all).and_return({
      "rule_1" => { is_valid: false, severity: "error" },
      "rule_2" => { is_valid: true, severity: "warning" }
    })
  end
end
