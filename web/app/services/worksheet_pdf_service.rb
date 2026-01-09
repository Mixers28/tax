require "open3"

class WorksheetPdfService
  def initialize(tax_return, export)
    @tax_return = tax_return
    @export = export
  end

  def generate
    html_path = WorksheetExportService.new(@tax_return, @export).generate
    pdf_path = build_pdf_path

    if wkhtmltopdf_available?
      success = render_with_wkhtmltopdf(html_path, pdf_path)
      return pdf_path if success
    end

    PDFExportService.new(@tax_return, @export).generate
  end

  private

  def build_pdf_path
    storage_dir = Rails.root.join("storage", "exports", @tax_return.id.to_s)
    FileUtils.mkdir_p(storage_dir)
    filename = "worksheet_#{@tax_return.id}_#{Time.current.to_i}.pdf"
    storage_dir.join(filename).to_s
  end

  def wkhtmltopdf_available?
    wkhtmltopdf_executable && system(wkhtmltopdf_executable, "--version", out: File::NULL, err: File::NULL)
  end

  def render_with_wkhtmltopdf(html_path, pdf_path)
    stdout, stderr, status = Open3.capture3(
      wkhtmltopdf_executable,
      "--encoding",
      "UTF-8",
      "--print-media-type",
      "--enable-local-file-access",
      html_path.to_s,
      pdf_path.to_s
    )

    unless status.success?
      Rails.logger.error("wkhtmltopdf failed: #{stderr.presence || stdout}")
      return false
    end

    true
  end

  def wkhtmltopdf_executable
    @wkhtmltopdf_executable ||= ENV["WKHTMLTOPDF_PATH"].presence || "wkhtmltopdf"
  end
end
