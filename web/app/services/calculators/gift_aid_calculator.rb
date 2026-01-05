class Calculators::GiftAidCalculator
  def initialize(tax_return)
    @tax_return = tax_return
  end

  def calculate
    # Gift Aid Calculator
    # For every £X donated, add £X * 25/75 gross-up
    # Gross donation = Donation + Gross-up

    cash_donated = fetch_box_value("SA110", "DAI", "1")

    return result_error("No Gift Aid donation amount found") unless cash_donated

    donated = parse_value(cash_donated)
    return result_error("Donation amount must be positive") if donated < 0

    # Gross-up calculation: Donation × 25/75
    gross_up = (donated * 25.0 / 75.0).round(2)
    total_gross = (donated + gross_up).round(2)

    # Tax relief available (basic rate): donated × 20%
    basic_rate_relief = (donated * 0.2).round(2)

    {
      success: true,
      calculation_type: "gift_aid",
      input_values: {
        cash_donated: donated
      },
      calculation_steps: [
        { label: "Cash donation", value: donated },
        { label: "Gross-up at 25/75 (0.333...)", value: gross_up },
        { label: "Total gross donation", value: total_gross },
        { label: "Basic rate tax relief (20%)", value: basic_rate_relief }
      ],
      output_value: total_gross,
      relief_available: basic_rate_relief,
      confidence: 1.0,
      formula: "Gross = Donation × (1 + 25/75) = Donation × 1.333..."
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
      calculation_type: "gift_aid"
    }
  end
end
