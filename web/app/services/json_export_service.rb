class JsonExportService
  def initialize(tax_return, export)
    @tax_return = tax_return
    @export = export
  end

  def generate
    output = {
      metadata: serialize_metadata,
      box_values: serialize_box_values,
      template_fields: serialize_template_fields,
      fx_provenance: serialize_fx_provenance,
      validations: serialize_validations,
      calculations: serialize_calculations,
      evidence_index: serialize_evidence_index,
      audit_trail: serialize_audit_trail
    }

    store_json(output)
  end

  private

  def serialize_metadata
    {
      export_id: @export.id,
      tax_year: @tax_return.tax_year.label,
      exported_at: @export.exported_at.iso8601,
      export_hash: @export.file_hash,
      export_format: "json",
      user_id: @export.user_id
    }
  end

  def serialize_box_values
    @tax_return.box_values.includes(:box_definition, :evidences, :fx_provenance).map do |bv|
      {
        box_code: bv.box_definition.box_code,
        box_name: bv.box_definition.hmrc_label,
        value: bv.value_raw,
        currency: bv.currency || "GBP",
        note: bv.note,
        evidence_ids: bv.evidence_ids,
        fx_provenance_id: bv.fx_provenance&.id,
        validation_status: bv.validation_status.to_s,
        created_at: bv.created_at.iso8601,
        updated_at: bv.updated_at.iso8601
      }
    end
  end

  def serialize_validations
    state = @export.validation_state || {}

    # validation_state is a summary hash with keys: total, passed, failed, errors, warnings, info
    {
      total: state["total"] || 0,
      passed: state["passed"] || 0,
      failed: state["failed"] || 0,
      errors: (state["errors"] || []).length,
      warnings: (state["warnings"] || []).length,
      error_details: state["errors"] || [],
      warning_details: state["warnings"] || []
    }
  end

  def serialize_calculations
    (@export.calculation_results || {}).map do |calc_type, result|
      # Handle both symbol and string keys (JSON storage converts symbols to strings)
      success = result[:success] || result["success"]
      next nil unless success

      {
        calculation_type: result[:calculation_type] || result["calculation_type"],
        formula: result[:formula] || result["formula"],
        input_values: result[:input_values] || result["input_values"],
        calculation_steps: result[:calculation_steps] || result["calculation_steps"],
        output_value: result[:output_value] || result["output_value"],
        confidence: result[:confidence] || result["confidence"]
      }
    end.compact
  end

  def serialize_evidence_index
    ExportEvidence.where(export: @export).includes(:evidence).map do |ee|
      evidence = ee.evidence

      {
        evidence_id: evidence.id,
        filename: evidence.filename,
        content_type: evidence.mime,
        sha256_hash: evidence.sha256,
        uploaded_at: evidence.created_at.iso8601,
        referenced_in_boxes: ee.referenced_in_values,
        linked_fields: EvidenceLink.where(evidence: evidence, linkable_type: "FieldValue").pluck(:linkable_id)
      }
    end
  end

  def serialize_template_fields
    workspace = @tax_return.return_workspace
    return [] unless workspace

    workspace.field_values.includes(:template_field, :evidence_links, :fx_provenance).map do |field_value|
      template_field = field_value.template_field
      {
        template_field_id: template_field.id,
        box_definition_id: template_field.box_definition_id,
        label: template_field.label,
        data_type: template_field.data_type,
        required: template_field.required,
        value: field_value.value_raw,
        note: field_value.note,
        confirmed_at: field_value.confirmed_at&.iso8601,
        evidence_ids: field_value.evidence_links.pluck(:evidence_id),
        fx_provenance_id: field_value.fx_provenance&.id
      }
    end
  end

  def serialize_fx_provenance
    workspace_fx = @tax_return.return_workspace&.field_values&.includes(:fx_provenance)&.map(&:fx_provenance) || []
    box_fx = @tax_return.box_values.includes(:fx_provenance).map(&:fx_provenance)
    (workspace_fx + box_fx).compact.uniq(&:id).map do |fx|
      {
        id: fx.id,
        provenanceable_type: fx.provenanceable_type,
        provenanceable_id: fx.provenanceable_id,
        original_amount: fx.original_amount,
        original_currency: fx.original_currency,
        gbp_amount: fx.gbp_amount,
        exchange_rate: fx.exchange_rate,
        rate_method: fx.rate_method,
        rate_period: fx.rate_period,
        rate_source: fx.rate_source,
        note: fx.note
      }
    end
  end

  def serialize_audit_trail
    begin
      AuditLog.where(object_ref: @tax_return.id).order(logged_at: :desc).limit(50).map do |audit|
        {
          timestamp: audit.logged_at.iso8601,
          action: audit.action,
          object_ref: audit.object_ref,
          before_state: audit.before_state,
          after_state: audit.after_state
        }
      end
    rescue
      # Return empty array if audit log is not available
      []
    end
  end

  def store_json(data)
    storage_dir = Rails.root.join("storage", "exports", @tax_return.id.to_s)
    FileUtils.mkdir_p(storage_dir)

    filename = "tax_return_#{@tax_return.id}_#{Time.current.to_i}.json"
    file_path = storage_dir.join(filename)

    File.write(file_path, JSON.pretty_generate(data))
    file_path.to_s
  end
end
