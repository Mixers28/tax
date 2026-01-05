require "prawn"

class PDFExportService
  def initialize(tax_return, export)
    @tax_return = tax_return
    @export = export
    # Use DejaVuSans font which supports UTF-8 characters including German umlauts
    @pdf = Prawn::Document.new(
      margin: 40,
      skip_page_creation: false
    )
    # Register DejaVu fonts for full UTF-8 support
    font_path = "#{Prawn::BASEDIR}/data/fonts"
    @pdf.font_families.update(
      "DejaVu" => {
        normal: "#{font_path}/DejaVuSans.ttf",
        bold: "#{font_path}/DejaVuSans-Bold.ttf",
        italic: "#{font_path}/DejaVuSans-Oblique.ttf",
        bold_italic: "#{font_path}/DejaVuSans-BoldOblique.ttf"
      }
    )
    @pdf.font("DejaVu")
  end

  def generate
    add_title_page
    add_box_values_section
    add_validation_section
    add_calculations_section
    add_evidence_section

    output_path = store_pdf
    output_path
  end

  private

  def add_title_page
    @pdf.text "UK Self Assessment Tax Return Export", size: 24, weight: :bold
    @pdf.move_down 10
    @pdf.text "Tax Year: #{@tax_return.tax_year.label}", size: 14
    @pdf.text "Export Date: #{@export.exported_at.strftime('%d %B %Y at %H:%M:%S')}", size: 12
    @pdf.move_down 20

    if @export.file_hash.present?
      @pdf.text "Export Hash: #{@export.file_hash}", size: 10, font: "Courier"
    end
    @pdf.move_down 20
    @pdf.text "This export contains all tax box values, validation results, and calculated relief amounts.", style: :italic, size: 10
  end

  def add_box_values_section
    @pdf.move_down 20
    @pdf.text "Section 1: Box Values", size: 16, weight: :bold
    @pdf.move_down 10

    box_values = @tax_return.box_values.includes(:box_definition).to_a

    if box_values.any?
      box_values.each do |bv|
        value_display = bv.value_gbp.present? ? "£#{bv.value_gbp}" : bv.value_raw.to_s
        status = bv.value_raw.present? ? "✓ Filled" : "✗ Empty"

        @pdf.text "Box #{bv.box_definition.box_code}: #{value_display} [#{status}]", size: 11
      end
    else
      @pdf.text "No box values entered", style: :italic, color: "999999"
    end
  end

  def add_validation_section
    @pdf.move_down 20
    @pdf.text "Section 2: Validation Results", size: 16, weight: :bold
    @pdf.move_down 10

    if @export.validation_state.present?
      summary = @export.validation_summary
      @pdf.text "Total Rules Checked: #{summary[:total]}", size: 11
      @pdf.text "Valid: #{summary[:valid]} ✓", size: 11, color: "00AA00"
      @pdf.text "Errors: #{summary[:errors]}", size: 11, color: summary[:errors].to_i > 0 ? "AA0000" : "000000"
      @pdf.text "Warnings: #{summary[:warnings]}", size: 11, color: summary[:warnings].to_i > 0 ? "FF6600" : "000000"
    else
      @pdf.text "No validation data available", style: :italic, color: "999999"
    end
  end

  def add_calculations_section
    @pdf.move_down 20
    @pdf.text "Section 3: Tax Calculations", size: 16, weight: :bold
    @pdf.move_down 10

    calculations = @export.calculation_results || {}

    if calculations.empty?
      @pdf.text "No calculations available", style: :italic, color: "999999"
      return
    end

    calculations.each do |calc_type, result|
      # Handle both symbol and string keys (JSON storage converts symbols to strings)
      success = result[:success] || result["success"]
      next unless success

      calc_name = (result[:calculation_type] || result["calculation_type"])&.upcase || calc_type&.upcase || "Unknown"
      @pdf.text "#{calc_name}", weight: :bold, size: 12, color: "0066CC"
      @pdf.move_down 5

      steps = result[:calculation_steps] || result["calculation_steps"]
      if steps.present?
        steps.each do |step|
          label = step[:label] || step["label"]
          value = step[:value] || step["value"]
          @pdf.text "  • #{label}: £#{value.to_f.round(2)}", size: 10
        end
      end

      output = result[:output_value] || result["output_value"]
      @pdf.text "  Result: £#{output.to_f.round(2)}", weight: :bold, size: 11, color: "00AA00"
      @pdf.move_down 10
    end
  end

  def add_evidence_section
    @pdf.move_down 20
    @pdf.text "Section 4: Evidence Files", size: 16, weight: :bold
    @pdf.move_down 10

    evidences = @tax_return.evidences.to_a

    if evidences.any?
      @pdf.text "Total Evidence Files: #{evidences.count}", size: 11
      @pdf.move_down 5

      evidences.each do |evidence|
        evidence_type = evidence.evidence_type == "blank_form" ? "📄 Form" : "📎 Doc"
        upload_date = evidence.created_at.strftime("%d %b %Y")
        @pdf.text "  • [#{evidence_type}] #{evidence.filename} (#{upload_date})", size: 10
      end
    else
      @pdf.text "No evidence files", style: :italic, color: "999999"
    end
  end

  def store_pdf
    storage_dir = Rails.root.join("storage", "exports", @tax_return.id.to_s)
    FileUtils.mkdir_p(storage_dir)

    filename = "tax_return_#{@tax_return.id}_#{Time.current.to_i}.pdf"
    file_path = storage_dir.join(filename)

    @pdf.render_file(file_path)
    file_path.to_s
  end
end
