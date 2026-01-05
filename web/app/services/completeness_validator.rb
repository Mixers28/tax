class CompletenessValidator
  def initialize(tax_return)
    @tax_return = tax_return
  end

  def validate
    rules = ValidationRule.active.by_type("completeness")
    results = []

    rules.each do |rule|
      next unless rule_applies?(rule)

      is_valid, message, affected_boxes = check_rule(rule)

      # Store validation result
      affected_boxes.each do |box_id|
        box_value = @tax_return.box_values.find_by(box_definition_id: box_id)
        next unless box_value

        BoxValidation.find_or_create_by!(
          box_value: box_value,
          validation_rule: rule
        ).update!(
          is_valid: is_valid,
          error_message: is_valid ? nil : message,
          validated_at: Time.current
        )
      end

      results << {
        rule_code: rule.rule_code,
        is_valid: is_valid,
        message: message
      }
    end

    results
  end

  private

  def rule_applies?(rule)
    return true if rule.form_definition_id.nil?

    @tax_return.box_values.exists?(
      box_definition: { page_definition: { form_definition_id: rule.form_definition_id } }
    )
  end

  def check_rule(rule)
    required_boxes = rule.required_field_box_ids || []
    return [true, "No required boxes defined", []] if required_boxes.empty?

    missing_boxes = []
    required_boxes.each do |box_id|
      box_value = @tax_return.box_values.find_by(box_definition_id: box_id)
      missing_boxes << box_id if box_value.nil? || box_value.value_raw.blank?
    end

    if missing_boxes.any?
      [
        false,
        "Missing required values: #{missing_boxes.length} boxes",
        missing_boxes
      ]
    else
      [
        true,
        "All required fields present",
        required_boxes
      ]
    end
  end
end
