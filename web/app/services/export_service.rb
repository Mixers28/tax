require_relative 'pdf_export_service'
require_relative 'json_export_service'

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

    # Tax Liability (Phase 5a)
    begin
      if @tax_return.income_sources.any?
        orchestrator = TaxCalculations::TaxLiabilityOrchestrator.new(@tax_return)
        liability = orchestrator.calculate

        results["tax_liability"] = {
          success: true,
          calculation_type: "tax_liability",
          output_value: liability.net_liability,
          calculation_steps: [
            { label: "Total Gross Income", value: liability.total_gross_income },
            { label: "Personal Allowance (Base)", value: liability.personal_allowance_base },
            { label: "Blind Person's Allowance", value: liability.blind_persons_allowance },
            { label: "Total Personal Allowance", value: liability.personal_allowance_total },
            { label: "Pension Contributions (Gross)", value: liability.pension_contributions_gross },
            { label: "Pension Relief at Source", value: liability.pension_relief_at_source },
            { label: "Rental Property Income", value: liability.rental_property_income },
            { label: "Furnished Property Relief (FTCR)", value: liability.furnished_property_relief },
            { label: "Taxable Income", value: liability.taxable_income },
            { label: "Gift Aid Donations (Net)", value: liability.gift_aid_donations_net },
            { label: "Gift Aid Gross-up", value: liability.gift_aid_gross_up },
            { label: "Gift Aid Band Extension", value: liability.gift_aid_extended_band },
            { label: "Basic Rate Tax", value: liability.basic_rate_tax },
            { label: "Higher Rate Tax", value: liability.higher_rate_tax },
            { label: "Additional Rate Tax", value: liability.additional_rate_tax },
            { label: "Total Income Tax", value: liability.total_income_tax },
            { label: "Class 1 NI", value: liability.class_1_ni },
            { label: "Class 2 NI", value: liability.class_2_ni },
            { label: "Class 4 NI", value: liability.class_4_ni },
            { label: "Total NI", value: liability.total_ni },
            { label: "High Income Child Benefit Charge", value: liability.hicbc_charge },
            { label: "Total Tax & NI", value: liability.total_tax_and_ni },
            { label: "Tax Paid at Source", value: liability.tax_paid_at_source },
            { label: "Net Liability", value: liability.net_liability }
          ]
        }
      end
    rescue => e
      Rails.logger.error("Tax Liability calculation failed: #{e.message}")
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
