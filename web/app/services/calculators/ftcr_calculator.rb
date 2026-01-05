class Calculators::FtcrCalculator
  def initialize(tax_return)
    @tax_return = tax_return
  end

  def calculate
    # FTCR (Furnished Temporary Accommodation) Relief
    # For 2024-25: Relief = Minimum of 50% of net rental income or qualifying expenses
    # Maximum relief: 50% of net income

    rental_income = fetch_box_value("SA102", "TR", "1")
    qualifying_expenses = fetch_box_value("SA102", "TR", "2")

    return result_error("Missing rental income data") unless rental_income
    return result_error("Missing qualifying expenses data") unless qualifying_expenses

    income = parse_value(rental_income)
    expenses = parse_value(qualifying_expenses)

    net_income = income - expenses
    return result_error("Net rental income is negative") if net_income < 0

    # FTCR relief is 50% of net rental income (maximum)
    ftcr_relief = (net_income * 0.5).round(2)

    # Taxable amount = net income - FTCR relief
    taxable_amount = (net_income - ftcr_relief).round(2)

    {
      success: true,
      calculation_type: "ftcr",
      input_values: {
        rental_income: income,
        qualifying_expenses: expenses,
        net_income: net_income
      },
      calculation_steps: [
        { label: "Rental income", value: income },
        { label: "Less: Qualifying expenses", value: expenses },
        { label: "Net rental income", value: net_income },
        { label: "FTCR relief (50% of net)", value: ftcr_relief },
        { label: "Taxable rental income", value: taxable_amount }
      ],
      output_value: taxable_amount,
      confidence: 1.0,
      formula: "Taxable = (Rental Income - Expenses) - (50% × Net Income)"
    }
  end

  private

  def fetch_box_value(form_code, page_code, box_code)
    form_def = FormDefinition.find_by(code: form_code)
    return nil unless form_def

    page_def = PageDefinition.find_by(form_definition_id: form_def.id, page_code: page_code)
    return nil unless page_def

    box_def = BoxDefinition.find_by(page_definition_id: page_def.id, box_code: box_code.to_s, instance: 1)
    return nil unless box_def

    @tax_return.box_values.find_by(box_definition_id: box_def.id)
  end

  def parse_value(box_value)
    return 0 if box_value.nil?

    value = box_value.value_raw.to_s.gsub(/[^0-9.-]/, "").to_f
    value.round(2)
  end

  def result_error(message)
    {
      success: false,
      error: message,
      calculation_type: "ftcr"
    }
  end
end
