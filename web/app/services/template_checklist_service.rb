class TemplateChecklistService
  ChecklistItem = Struct.new(
    :template_field,
    :field_value,
    :missing_value,
    :missing_confirmation,
    :missing_evidence,
    :evidence_status,
    keyword_init: true
  )

  ChecklistSummary = Struct.new(
    :total,
    :required,
    :missing_value,
    :missing_confirmation,
    :missing_evidence,
    keyword_init: true
  )

  def initialize(tax_return)
    @tax_return = tax_return
  end

  def call
    workspace = @tax_return.return_workspace
    return { items: [], summary: ChecklistSummary.new(total: 0, required: 0, missing_value: 0, missing_confirmation: 0, missing_evidence: 0) } unless workspace

    evidence_index = build_evidence_index
    field_evidence_index = build_field_evidence_index(workspace)
    items = workspace.field_values.includes(template_field: :box_definition, evidence_links: []).joins(:template_field)
      .order(Arel.sql("template_fields.position ASC NULLS LAST, template_fields.id ASC"))
      .map do |field_value|
        template_field = field_value.template_field
        missing_value = template_field.required? && field_value.value_raw.blank?
        missing_confirmation = template_field.required? && field_value.confirmed_at.nil?
        evidence_status = resolve_evidence_status(template_field, field_value, evidence_index, field_evidence_index)
        missing_evidence = template_field.required? && evidence_status == :missing

        ChecklistItem.new(
          template_field: template_field,
          field_value: field_value,
          missing_value: missing_value,
          missing_confirmation: missing_confirmation,
          missing_evidence: missing_evidence,
          evidence_status: evidence_status
        )
      end

    summary = ChecklistSummary.new(
      total: items.size,
      required: items.count { |item| item.template_field.required? },
      missing_value: items.count(&:missing_value),
      missing_confirmation: items.count(&:missing_confirmation),
      missing_evidence: items.count(&:missing_evidence)
    )

    { items: items, summary: summary }
  end

  private

  def build_evidence_index
    @tax_return.box_values.includes(:evidences).each_with_object({}) do |box_value, index|
      index[box_value.box_definition_id] = box_value.evidences.any?
    end
  end

  def build_field_evidence_index(workspace)
    workspace.field_values.includes(:evidence_links).each_with_object({}) do |field_value, index|
      index[field_value.id] = field_value.evidence_links.any?
    end
  end

  def resolve_evidence_status(template_field, field_value, evidence_index, field_evidence_index)
    return :present if field_evidence_index[field_value.id]
    return :missing unless template_field.box_definition_id

    evidence_index.fetch(template_field.box_definition_id, false) ? :present : :missing
  end
end
