require "test_helper"

class Calculators::FTCRCalculatorTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    # Create SA102 form structure
    @form = FormDefinition.create!(code: "SA102")
    @page = PageDefinition.create!(form_definition: @form, page_code: "TR")
    @income_box = BoxDefinition.create!(
      page_definition: @page,
      box_code: "1",
      instance: 1,
      label: "Rental Income"
    )
    @expenses_box = BoxDefinition.create!(
      page_definition: @page,
      box_code: "2",
      instance: 1,
      label: "Expenses"
    )
  end

  test "calculates FTCR relief correctly" do
    # Setup: Rental income £10,000, expenses £6,000
    # Net: £4,000
    # FTCR relief: £2,000 (50% of £4,000)
    # Taxable: £2,000

    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "10000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    calculator = Calculators::FTCRCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 2000.0, result[:output_value]
    assert_equal 1.0, result[:confidence]
    assert_equal "ftcr", result[:calculation_type]
  end

  test "handles zero net income" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "5000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "5000")

    calculator = Calculators::FTCRCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 0.0, result[:output_value]
  end

  test "handles negative net income" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "5000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    calculator = Calculators::FTCRCalculator.new(@tax_return)
    result = calculator.calculate

    assert !result[:success]
    assert result[:error].include?("negative")
  end

  test "returns calculation steps" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "10000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    calculator = Calculators::FTCRCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:calculation_steps].is_a?(Array)
    assert result[:calculation_steps].length > 0
    assert result[:calculation_steps][0][:label] == "Rental income"
  end

  test "handles missing rental income" do
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    calculator = Calculators::FTCRCalculator.new(@tax_return)
    result = calculator.calculate

    assert !result[:success]
  end

  test "handles currency formatting in values" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "£10,000.50")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "£6,000.25")

    calculator = Calculators::FTCRCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert result[:input_values][:rental_income] == 10000.5
  end

  test "formula in result" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "10000")
    @tax_return.box_values.create!(box_definition: @expenses_box, value_raw: "6000")

    calculator = Calculators::FTCRCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:formula].include?("50%")
  end
end
