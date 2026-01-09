class WorksheetDataService
  def initialize(tax_return)
    @tax_return = tax_return
  end

  def call
    workspace = @tax_return.return_workspace
    template_profile = workspace&.template_profile

    rows = if template_profile&.template_fields&.any?
      build_from_template(workspace, template_profile)
    else
      build_from_box_values
    end
    schedules = build_schedules(rows)

    {
      generated_at: Time.current,
      forms: group_rows(rows),
      schedules: schedules,
      tr7_note: build_tr7_note(rows, schedules)
    }
  end

  private

  def build_from_template(workspace, template_profile)
    field_values = workspace.field_values
      .includes(:fx_provenance, evidence_links: :evidence)
      .index_by(&:template_field_id)
    field_evidence_index = workspace.field_values
      .includes(evidence_links: :evidence)
      .each_with_object({}) { |field_value, index| index[field_value.id] = evidence_names(field_value.evidence_links) }
    box_values = @tax_return.box_values
      .includes(:box_definition, :fx_provenance, :evidences)
      .index_by(&:box_definition_id)
    box_evidence_index = @tax_return.box_values
      .includes(:evidences)
      .each_with_object({}) { |box_value, index| index[box_value.box_definition_id] = evidence_names(box_value.evidences) }

    template_profile.template_fields
      .includes(box_definition: { page_definition: :form_definition })
      .order(:position, :id)
      .map.with_index do |template_field, index|
        box_definition = template_field.box_definition
        page_definition = box_definition&.page_definition
        form_definition = page_definition&.form_definition
        field_value = field_values[template_field.id]
        box_value = box_definition ? box_values[box_definition.id] : nil

        value_raw = field_value&.value_raw.presence || box_value&.value_raw
        note = field_value&.note.presence || box_value&.note
        evidence = (field_evidence_index[field_value&.id] || []) + (box_evidence_index[box_definition&.id] || [])
        fx_summary = format_fx(field_value&.fx_provenance || box_value&.fx_provenance)

        {
          order: index,
          form_code: form_definition&.code || "Custom",
          form_year: form_definition&.year,
          page_code: page_definition&.page_code || "General",
          box_code: box_definition&.box_code,
          label: template_field.label.presence || box_definition&.hmrc_label || "Custom field",
          value: format_value(box_value, value_raw),
          note: note,
          evidence: evidence.uniq,
          fx_summary: fx_summary,
          required: template_field.required?
        }
      end
  end

  def build_from_box_values
    @tax_return.box_values
      .includes(:evidences, :fx_provenance, box_definition: { page_definition: :form_definition })
      .map.with_index do |box_value, index|
      box_definition = box_value.box_definition
      page_definition = box_definition.page_definition
      form_definition = page_definition.form_definition

      {
        order: index,
        form_code: form_definition.code,
        form_year: form_definition.year,
        page_code: page_definition.page_code,
        box_code: box_definition.box_code,
        label: box_definition.hmrc_label,
        value: format_value(box_value, box_value.value_raw),
        note: box_value.note,
        evidence: evidence_names(box_value.evidences),
        fx_summary: format_fx(box_value.fx_provenance),
        required: false
      }
    end
  end

  def group_rows(rows)
    rows.group_by { |row| row[:form_code] }.map do |form_code, form_rows|
      form_order = form_rows.map { |row| row[:order] }.min
      pages = form_rows.group_by { |row| row[:page_code] }.map do |page_code, page_rows|
        page_order = page_rows.map { |row| row[:order] }.min
        {
          code: page_code,
          order: page_order,
          rows: page_rows.sort_by { |row| row[:order] }
        }
      end.sort_by { |page| page[:order] }

      {
        code: form_code,
        year: form_rows.map { |row| row[:form_year] }.compact.first,
        order: form_order,
        pages: pages
      }
    end.sort_by { |form| form[:order] }
  end

  def build_schedules(rows)
    {
      sa106_f6: rows.select do |row|
        row[:form_code].to_s.upcase == "SA106" && row[:page_code].to_s.upcase == "F6"
      end
    }
  end

  def build_tr7_note(rows, schedules)
    return nil unless schedules[:sa106_f6].present?

    target = if rows.any? { |row| row[:form_code].to_s.upcase == "SA102" }
      "SA102 (Employment)"
    elsif rows.any? { |row| row[:form_code].to_s.upcase == "SA100" }
      "SA100 (Main return)"
    else
      "the relevant return pages"
    end

    "TR7: Foreign income and tax reported in SA106 F6 are included in #{target}. See the SA106 F6 schedule for detail."
  end

  def format_value(box_value, value_raw)
    return "" if value_raw.blank? && box_value&.value_gbp.blank?

    if box_value&.value_gbp.present?
      "£#{box_value.value_gbp}"
    else
      value_raw.to_s
    end
  end

  def evidence_names(evidence_records)
    Array(evidence_records).map(&:filename).compact
  end

  def format_fx(fx_provenance)
    return nil unless fx_provenance

    parts = []
    if fx_provenance.original_amount.present? && fx_provenance.original_currency.present?
      parts << "#{fx_provenance.original_amount} #{fx_provenance.original_currency}"
    end
    parts << "GBP #{fx_provenance.gbp_amount}" if fx_provenance.gbp_amount.present?
    parts << "@ #{fx_provenance.exchange_rate}" if fx_provenance.exchange_rate.present?
    parts << fx_provenance.rate_source if fx_provenance.rate_source.present?
    parts.empty? ? nil : parts.join(" ")
  end
end
