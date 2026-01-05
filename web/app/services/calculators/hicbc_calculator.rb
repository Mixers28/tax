class Calculators::HicbcCalculator
  # HICBC threshold for 2024-25
  HICBC_THRESHOLD = 60_000
  HICBC_RATE = 0.01 # 1%

  def initialize(tax_return)
    @tax_return = tax_return
  end

  def calculate
    # HICBC (High Income Child Benefit Charge)
    # If net income > £60,000, charge = 1% of child benefit for every £1 above threshold
    # Maximum charge = 100% of child benefit received

    net_income = calculate_total_net_income
    child_benefit = fetch_box_value("SA100", "DR", "1")

    return result_error("Unable to calculate total net income") unless net_income
    return result_error("No child benefit amount found") unless child_benefit

    benefit_amount = parse_value(child_benefit)
    return result_error("Child benefit must be positive") if benefit_amount < 0

    # Calculate excess income over threshold
    excess_income = net_income - HICBC_THRESHOLD
    return {
      success: true,
      calculation_type: "hicbc",
      input_values: {
        net_income: net_income,
        child_benefit: benefit_amount
      },
      calculation_steps: [
        { label: "Total net income", value: net_income },
        { label: "HICBC threshold", value: HICBC_THRESHOLD },
        { label: "Income above threshold", value: 0 },
        { label: "Child benefit received", value: benefit_amount },
        { label: "HICBC charge", value: 0 }
      ],
      output_value: 0,
      confidence: 1.0,
      reason: "Income below HICBC threshold"
    } if excess_income <= 0

    # Charge = excess income × 1% of child benefit, capped at child benefit amount
    charge_percentage = (excess_income * HICBC_RATE / 100).round(4)
    hicbc_charge = (benefit_amount * charge_percentage).round(2)

    # Cap at 100% of child benefit
    hicbc_charge = benefit_amount if hicbc_charge > benefit_amount

    {
      success: true,
      calculation_type: "hicbc",
      input_values: {
        net_income: net_income,
        child_benefit: benefit_amount
      },
      calculation_steps: [
        { label: "Total net income", value: net_income },
        { label: "HICBC threshold", value: HICBC_THRESHOLD },
        { label: "Income above threshold", value: excess_income },
        { label: "Excess × 1%", value: charge_percentage.to_f },
        { label: "Child benefit received", value: benefit_amount },
        { label: "HICBC charge", value: hicbc_charge }
      ],
      output_value: hicbc_charge,
      confidence: 1.0,
      formula: "HICBC = Child Benefit × ((Net Income - £60,000) × 1%), capped at CB amount"
    }
  end

  private

  def calculate_total_net_income
    # Sum all income sources from relevant boxes
    # For simplicity, fetch SA100 total income
    sa100_total = fetch_box_value("SA100", "1", "1")

    if sa100_total
      parse_value(sa100_total)
    else
      # Calculate from component sources if available
      nil
    end
  end

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
      calculation_type: "hicbc"
    }
  end
end
