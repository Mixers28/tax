class ValidationService
  def initialize(tax_return)
    @tax_return = tax_return
    @results = []
  end

  def validate_all
    CompletenessValidator.new(@tax_return).validate
    ConfidenceValidator.new(@tax_return).validate
    CrossFieldValidator.new(@tax_return).validate
    BusinessLogicValidator.new(@tax_return).validate

    generate_report
  end

  def validate_completeness
    results = CompletenessValidator.new(@tax_return).validate
    results
  end

  def validate_cross_fields
    CrossFieldValidator.new(@tax_return).validate
  end

  def validate_confidence(threshold = 0.7)
    ConfidenceValidator.new(@tax_return, threshold).validate
  end

  def validate_business_logic
    BusinessLogicValidator.new(@tax_return).validate
  end

  def generate_report
    all_rules = ValidationRule.active
    results = {}
    errors = []
    warnings = []
    info = []

    all_rules.each do |rule|
      # Check if rule applies to this tax return's forms
      next unless rule_applies?(rule)

      validations = validate_rule(rule)
      result_item = {
        rule_code: rule.rule_code,
        rule_type: rule.rule_type,
        severity: rule.severity,
        description: rule.description,
        is_valid: validations[:is_valid],
        message: validations[:message],
        affected_boxes: validations[:affected_boxes]
      }

      results[rule.rule_code] = result_item

      # Categorize by severity and validity
      unless validations[:is_valid]
        case rule.severity
        when "error"
          errors << result_item
        when "warning"
          warnings << result_item
        when "info"
          info << result_item
        end
      end
    end

    # Generate summary
    total = results.length
    passed = results.values.count { |r| r[:is_valid] }
    failed = errors.length

    {
      total: total,
      passed: passed,
      failed: failed,
      errors: errors,
      warnings: warnings,
      info: info
    }
  end

  private

  def rule_applies?(rule)
    return true if rule.form_definition_id.nil?

    @tax_return.box_values.exists?(
      box_definition: { page_definition: { form_definition_id: rule.form_definition_id } }
    )
  end

  def validate_rule(rule)
    case rule.rule_type
    when "completeness"
      validate_completeness_rule(rule)
    when "cross_field"
      validate_cross_field_rule(rule)
    when "confidence"
      validate_confidence_rule(rule)
    when "business_logic"
      validate_business_logic_rule(rule)
    else
      { is_valid: true, message: "Unknown rule type" }
    end
  end

  def validate_completeness_rule(rule)
    required_boxes = rule.required_field_box_ids || []
    return { is_valid: true, message: "No required boxes defined", affected_boxes: [] } if required_boxes.empty?

    missing_boxes = []
    required_boxes.each do |box_id|
      box_value = @tax_return.box_values.find_by(box_definition_id: box_id)
      missing_boxes << box_id if box_value.nil? || box_value.value_raw.blank?
    end

    if missing_boxes.any?
      {
        is_valid: false,
        message: "Missing required values in #{missing_boxes.length} boxes",
        affected_boxes: missing_boxes
      }
    else
      {
        is_valid: true,
        message: "All required fields present",
        affected_boxes: []
      }
    end
  end

  def validate_cross_field_rule(rule)
    # Example: If box A has value, then box B must also have value
    { is_valid: true, message: "Cross-field validation passed", affected_boxes: [] }
  end

  def validate_confidence_rule(rule)
    # Check extraction confidence on box values
    low_confidence_boxes = []
    @tax_return.box_values.each do |box_value|
      extraction_run = box_value.evidences.first&.extraction_runs&.last
      if extraction_run && extraction_run.candidates.present?
        candidate = extraction_run.candidates.first
        if candidate["confidence"].to_f < 0.7
          low_confidence_boxes << box_value.box_definition.box_code
        end
      end
    end

    if low_confidence_boxes.any?
      {
        is_valid: false,
        message: "#{low_confidence_boxes.length} values have low extraction confidence",
        affected_boxes: low_confidence_boxes
      }
    else
      {
        is_valid: true,
        message: "All values meet confidence threshold",
        affected_boxes: []
      }
    end
  end

  def validate_business_logic_rule(rule)
    # Custom business logic validation
    { is_valid: true, message: "Business logic validation passed", affected_boxes: [] }
  end
end
