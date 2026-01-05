class ExportsController < ApplicationController
  before_action :set_tax_return
  before_action :set_export, only: [:show, :download_pdf, :download_json]

  def index
    @exports = @tax_return.exports.order(created_at: :desc)
  end

  def review
    # Generate preview data for review
    @validation_results = ValidationService.new(@tax_return).generate_report
    @box_values = @tax_return.box_values.includes(:box_definition).order('box_definitions.box_code')
    @evidences = @tax_return.evidences.group_by(&:evidence_type)
    @calculations = @tax_return.tax_calculations.order(created_at: :desc)
  end

  def create
    format = params[:format] || "both"

    Rails.logger.info("Starting export generation with format: #{format}")

    export = ExportService.new(@tax_return, current_user, format).generate!

    Rails.logger.info("Export generation completed: #{export.id}")
    redirect_to tax_return_export_path(@tax_return, export), notice: "Export created successfully"
  rescue StandardError => e
    Rails.logger.error("Export creation failed: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    redirect_to tax_return_exports_path(@tax_return), alert: "Export failed: #{e.message}"
  end

  def show
    @validation_summary = @export.validation_summary
    @calculations = @export.calculation_results || {}
    @box_values = @tax_return.box_values.includes(:box_definition, :evidences)
    @evidence_links = ExportEvidence.where(export: @export).includes(:evidence)
  end

  def download_pdf
    if @export.file_path.present? && File.exist?(@export.file_path)
      send_file @export.file_path,
                filename: "tax_return_#{@tax_return.id}.pdf",
                type: "application/pdf",
                disposition: "attachment"
    else
      redirect_to tax_return_export_path(@tax_return, @export), alert: "PDF file not found"
    end
  end

  def download_json
    if @export.json_path.present? && File.exist?(@export.json_path)
      send_file @export.json_path,
                filename: "tax_return_#{@tax_return.id}.json",
                type: "application/json",
                disposition: "attachment"
    else
      redirect_to tax_return_export_path(@tax_return, @export), alert: "JSON file not found"
    end
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:tax_return_id])
  end

  def set_export
    @export = @tax_return.exports.find(params[:id])
  end
end
