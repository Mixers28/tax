require "test_helper"

class Calculators::GiftAidCalculatorTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    # Create SA110 form structure
    @form = FormDefinition.create!(code: "SA110")
    @page = PageDefinition.create!(form_definition: @form, page_code: "DAI")
    @donation_box = BoxDefinition.create!(
      page_definition: @page,
      box_code: "1",
      instance: 1,
      label: "Cash Donations"
    )
  end

  test "calculates gift aid gross-up correctly" do
    # Donation: £750
    # Gross-up: 750 * 25/75 = 250
    # Total gross: £1,000

    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "750")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 750.0, result[:input_values][:cash_donated]
    assert_equal 250.0, result[:output_value]
    assert_equal 1000.0, result[:calculation_steps].last[:value]
  end

  test "handles zero donation" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "0")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 0.0, result[:output_value]
  end

  test "handles negative donation" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "-100")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert !result[:success]
  end

  test "handles missing donation amount" do
    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert !result[:success]
  end

  test "calculates basic rate relief" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "100")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    # Relief: 100 * 20% = 20
    assert_equal 20.0, result[:relief_available]
  end

  test "returns calculation steps" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "100")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:calculation_steps].is_a?(Array)
    assert result[:calculation_steps].any? { |s| s[:label].include?("Cash donation") }
    assert result[:calculation_steps].any? { |s| s[:label].include?("Gross-up") }
  end

  test "formula includes gross-up rate" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "100")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:formula].include?("25/75")
  end

  test "handles large donation amounts" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "1000000")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 1000000.0, result[:input_values][:cash_donated]
    assert_equal 333333.33, result[:output_value]
  end

  test "decimal precision" do
    @tax_return.box_values.create!(box_definition: @donation_box, value_raw: "123.45")

    calculator = Calculators::GiftAidCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert result[:output_value].round(2) == (123.45 * 25.0 / 75.0).round(2)
  end
end
