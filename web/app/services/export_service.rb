class ExportService
  def initialize(tax_return, user, format = "both")
    @tax_return = tax_return
    @user = user
    @format = format
    @export = nil
  end

  def generate!
    # Create export record
    @export = Export.create!(
      tax_return: @tax_return,
      user: @user,
      format: @format,
      exported_at: Time.current
    )

    # Capture validation state
    validation_results = ValidationService.new(@tax_return).generate_report
    @export.update!(validation_state: validation_results)

    # Capture calculation results
    calculation_results = collect_calculations
    @export.update!(calculation_results: calculation_results)

    # Capture export snapshot of all box values
    snapshot = @tax_return.box_values.includes(:box_definition).map do |bv|
      {
        box_code: bv.box_definition.box_code,
        box_name: bv.box_definition.hmrc_label,
        value: bv.value_raw,
        note: bv.note,
        validation_status: bv.validation_status.to_s
      }
    end
    @export.update!(export_snapshot: snapshot)

    # Link evidence
    link_evidence

    # Generate PDF if requested
    if @export.pdf?
      begin
        pdf_path = PDFExportService.new(@tax_return, @export).generate
        @export.update!(file_path: pdf_path)
      rescue => e
        Rails.logger.error("PDF Export failed: #{e.message}\n#{e.backtrace.join("\n")}")
      end
    end

    # Generate JSON if requested
    if @export.json?
      begin
        json_path = JSONExportService.new(@tax_return, @export).generate
        @export.update!(json_path: json_path)
      rescue => e
        Rails.logger.error("JSON Export failed: #{e.message}\n#{e.backtrace.join("\n")}")
      end
    end

    # Generate file hash for integrity verification
    @export.update!(
      file_hash: generate_file_hash,
      exported_at: Time.current
    )

    @export
  end

  private

  def collect_calculations
    results = {}

    # FTCR
    begin
      ftcr_result = Calculators::FtcrCalculator.new(@tax_return).calculate
      results["ftcr"] = ftcr_result if ftcr_result[:success]
    rescue => e
      Rails.logger.error("FTCR calculation failed: #{e.message}")
    end

    # Gift Aid
    begin
      gift_aid_result = Calculators::GiftAidCalculator.new(@tax_return).calculate
      results["gift_aid"] = gift_aid_result if gift_aid_result[:success]
    rescue => e
      Rails.logger.error("Gift Aid calculation failed: #{e.message}")
    end

    # HICBC
    begin
      hicbc_result = Calculators::HicbcCalculator.new(@tax_return).calculate
      results["hicbc"] = hicbc_result if hicbc_result[:success]
    rescue => e
      Rails.logger.error("HICBC calculation failed: #{e.message}")
    end

    results
  end

  def link_evidence
    @tax_return.evidences.each do |evidence|
      # Find which box values reference this evidence
      referenced_values = evidence.box_values.pluck(:box_definition_id)

      ExportEvidence.find_or_create_by!(
        export: @export,
        evidence: evidence
      ).update!(
        referenced_in_values: referenced_values
      )
    end
  end

  def generate_file_hash
    # Create hash of export content for integrity verification
    content = {
      export_snapshot: @export.export_snapshot,
      validation_state: @export.validation_state,
      calculation_results: @export.calculation_results,
      timestamp: @export.exported_at
    }

    Digest::SHA256.hexdigest(content.to_json)
  end
end
