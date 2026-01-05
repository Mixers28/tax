class ConfidenceValidator
  MINIMUM_CONFIDENCE = 0.7

  def initialize(tax_return, threshold = MINIMUM_CONFIDENCE)
    @tax_return = tax_return
    @threshold = threshold
  end

  def validate
    rule = ValidationRule.find_or_create_by!(
      rule_code: "extraction_confidence",
      rule_type: "confidence",
      severity: "warning"
    ) do |r|
      r.description = "Flag values extracted with < #{@threshold * 100}% confidence"
    end

    low_confidence_boxes = []

    @tax_return.box_values.each do |box_value|
      confidence = extract_confidence(box_value)

      if confidence < @threshold
        low_confidence_boxes << box_value.box_definition.id

        BoxValidation.find_or_create_by!(
          box_value: box_value,
          validation_rule: rule
        ).update!(
          is_valid: false,
          warning_message: "Extracted with #{(confidence * 100).round(1)}% confidence",
          validated_at: Time.current
        )
      else
        BoxValidation.find_or_create_by!(
          box_value: box_value,
          validation_rule: rule
        ).update!(
          is_valid: true,
          warning_message: nil,
          validated_at: Time.current
        )
      end
    end

    [{
      rule_code: "extraction_confidence",
      is_valid: low_confidence_boxes.empty?,
      message: low_confidence_boxes.empty? ? "All values meet confidence threshold" : "#{low_confidence_boxes.length} values below threshold"
    }]
  end

  private

  def extract_confidence(box_value)
    # Get confidence from extraction run for this box value
    extraction = box_value.evidences.first&.extraction_runs&.last
    return 1.0 unless extraction  # Manual entries have 100% confidence

    candidates = extraction.candidates || []
    return 1.0 if candidates.empty?

    # Get the confidence of the first matching candidate
    candidate = candidates.first
    candidate&.dig("confidence")&.to_f || 0.5
  end
end
