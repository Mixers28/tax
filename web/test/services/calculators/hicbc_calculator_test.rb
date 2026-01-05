require "test_helper"

class Calculators::HICBCCalculatorTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    # Create SA100 form structure
    @form = FormDefinition.create!(code: "SA100")
    @page_sa100 = PageDefinition.create!(form_definition: @form, page_code: "1")
    @income_box = BoxDefinition.create!(
      page_definition: @page_sa100,
      box_code: "1",
      instance: 1,
      label: "Total Net Income"
    )

    @page_dr = PageDefinition.create!(form_definition: @form, page_code: "DR")
    @cb_box = BoxDefinition.create!(
      page_definition: @page_dr,
      box_code: "1",
      instance: 1,
      label: "Child Benefit"
    )
  end

  test "calculates HICBC below threshold" do
    # Income: £50,000, CB: £2,000
    # Below £60k threshold, so no charge

    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "50000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 0.0, result[:output_value]
    assert result[:reason].include?("below")
  end

  test "calculates HICBC at threshold" do
    # Income: £60,000, CB: £2,000
    # At threshold, no excess income, so no charge

    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "60000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 0.0, result[:output_value]
  end

  test "calculates HICBC above threshold" do
    # Income: £70,000, CB: £2,000
    # Excess: £10,000
    # Charge: 2000 * (10000 * 1% / 100) = 2000 * 0.01 = 20

    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert result[:output_value] > 0
    # Verify calculation steps
    assert result[:calculation_steps].any? { |s| s[:label].include?("above threshold") }
  end

  test "HICBC capped at child benefit amount" do
    # Income: £100,000 (way above threshold), CB: £2,000
    # Would calculate to > £2,000, but should be capped at £2,000

    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "100000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert result[:output_value] <= 2000.0
  end

  test "handles zero child benefit" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "0")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:success]
    assert_equal 0.0, result[:output_value]
  end

  test "handles negative child benefit" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "-100")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert !result[:success]
  end

  test "handles missing income data" do
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert !result[:success]
  end

  test "formula in result" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:formula].include?("£60,000")
    assert result[:formula].include?("1%")
  end

  test "returns calculation steps" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert result[:calculation_steps].is_a?(Array)
    assert result[:calculation_steps].any? { |s| s[:label].include?("income") }
    assert result[:calculation_steps].any? { |s| s[:label].include?("threshold") }
  end

  test "confidence is always 100 percent" do
    @tax_return.box_values.create!(box_definition: @income_box, value_raw: "70000")
    @tax_return.box_values.create!(box_definition: @cb_box, value_raw: "2000")

    calculator = Calculators::HICBCCalculator.new(@tax_return)
    result = calculator.calculate

    assert_equal 1.0, result[:confidence]
  end
end
