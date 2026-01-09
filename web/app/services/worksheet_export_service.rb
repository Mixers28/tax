class WorksheetExportService
  def initialize(tax_return, export = nil)
    @tax_return = tax_return
    @export = export
  end

  def generate
    worksheet = WorksheetDataService.new(@tax_return).call
    html = ApplicationController.render(
      template: "tax_returns/worksheet",
      assigns: { tax_return: @tax_return, worksheet: worksheet },
      layout: "application"
    )

    storage_dir = Rails.root.join("storage", "exports", @tax_return.id.to_s)
    FileUtils.mkdir_p(storage_dir)

    filename = "worksheet_#{@tax_return.id}_#{Time.current.to_i}.html"
    file_path = storage_dir.join(filename)
    File.write(file_path, html)
    file_path.to_s
  end
end
