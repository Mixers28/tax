require "test_helper"

class CalculationsControllerTest < ActionDispatch::IntegrationTest
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

    # Setup form structures for calculators
    setup_sa102_form
    setup_sa110_form

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: "password123" }
  end

  test "user can view calculations index" do
    get "/tax_returns/#{@tax_return.id}/calculations"
    assert_response :success
  end

  test "user cannot view other user's calculations" do
    get "/tax_returns/#{@other_tax_return.id}/calculations"
    assert_response :redirect
  end

  test "calculate_ftcr endpoint returns result" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "10000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    post "/tax_returns/#{@tax_return.id}/calculations/calculate_ftcr"

    assert_response :success
    result = JSON.parse(response.body)

    assert result["success"]
    assert_equal "ftcr", result["calculation_type"]
    assert result["output_value"].present?
    assert_equal 1.0, result["confidence"]
  end

  test "calculate_ftcr creates calculation record" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "10000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    post "/tax_returns/#{@tax_return.id}/calculations/calculate_ftcr"

    assert TaxCalculation.where(
      tax_return: @tax_return,
      calculation_type: "ftcr"
    ).exists?
  end

  test "calculate_gift_aid endpoint returns result" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "750")

    post "/tax_returns/#{@tax_return.id}/calculations/calculate_gift_aid"

    assert_response :success
    result = JSON.parse(response.body)

    assert result["success"]
    assert_equal "gift_aid", result["calculation_type"]
    assert result["output_value"].present?
  end

  test "calculate_gift_aid creates calculation record" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "750")

    post "/tax_returns/#{@tax_return.id}/calculations/calculate_gift_aid"

    assert TaxCalculation.where(
      tax_return: @tax_return,
      calculation_type: "gift_aid"
    ).exists?
  end

  test "calculate_hicbc endpoint returns result" do
    form_sa100 = FormDefinition.create!(code: "SA100")
    page1 = PageDefinition.create!(form_definition: form_sa100, page_code: "1")
    income_box = BoxDefinition.create!(
      page_definition: page1,
      box_code: "1",
      instance: 1,
      label: "Income"
    )
    page_dr = PageDefinition.create!(form_definition: form_sa100, page_code: "DR")
    cb_box = BoxDefinition.create!(
      page_definition: page_dr,
      box_code: "1",
      instance: 1,
      label: "CB"
    )

    @tax_return.box_values.create!(box_definition: income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: cb_box, value_raw: "2000")

    post "/tax_returns/#{@tax_return.id}/calculations/calculate_hicbc"

    assert_response :success
    result = JSON.parse(response.body)

    assert result["success"]
    assert_equal "hicbc", result["calculation_type"]
    assert result["output_value"].present?
  end

  test "calculate_hicbc creates calculation record" do
    form_sa100 = FormDefinition.create!(code: "SA100")
    page1 = PageDefinition.create!(form_definition: form_sa100, page_code: "1")
    income_box = BoxDefinition.create!(
      page_definition: page1,
      box_code: "1",
      instance: 1
    )
    page_dr = PageDefinition.create!(form_definition: form_sa100, page_code: "DR")
    cb_box = BoxDefinition.create!(
      page_definition: page_dr,
      box_code: "1",
      instance: 1
    )

    @tax_return.box_values.create!(box_definition: income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: cb_box, value_raw: "2000")

    post "/tax_returns/#{@tax_return.id}/calculations/calculate_hicbc"

    assert TaxCalculation.where(
      tax_return: @tax_return,
      calculation_type: "hicbc"
    ).exists?
  end

  test "calculation with invalid data returns error" do
    # FTCR with negative net income
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "5000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    post "/tax_returns/#{@tax_return.id}/calculations/calculate_ftcr"

    assert_response :unprocessable_entity
    result = JSON.parse(response.body)
    assert !result["success"]
    assert result["error"].present?
  end

  test "user cannot calculate for other user's return" do
    @other_tax_return.box_values.create!(box_definition: @donation_box, value_raw: "100")

    post "/tax_returns/#{@other_tax_return.id}/calculations/calculate_gift_aid"
    assert_response :redirect
  end

  private

  def setup_sa102_form
    form = FormDefinition.create!(code: "SA102")
    page = PageDefinition.create!(form_definition: form, page_code: "TR")
    @income_box = BoxDefinition.create!(
      page_definition: page,
      box_code: "1",
      instance: 1,
      label: "Income"
    )
    @expenses_box = BoxDefinition.create!(
      page_definition: page,
      box_code: "2",
      instance: 1,
      label: "Expenses"
    )
  end

  def setup_sa110_form
    form = FormDefinition.create!(code: "SA110")
    page = PageDefinition.create!(form_definition: form, page_code: "DAI")
    @donation_box = BoxDefinition.create!(
      page_definition: page,
      box_code: "1",
      instance: 1,
      label: "Donation"
    )
  end
end
