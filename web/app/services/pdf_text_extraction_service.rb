require "pdf/reader"

class PdfTextExtractionService
  class ExtractionError < StandardError; end

  def initialize(blob)
    @blob = blob
  end

  def extract
    raise ExtractionError, "Evidence file is missing" unless @blob

    unless pdf_content?(@blob)
      raise ExtractionError, "Evidence file is not a PDF"
    end

    text = ""
    begin
      @blob.open do |file|
        reader = PDF::Reader.new(file.path)
        text = reader.pages.map { |page| safe_extract_page_text(page) }.join("\n")
      end
    rescue PDF::Reader::MalformedPDFError => e
      raise ExtractionError, "PDF appears to be corrupted or malformed: #{e.message}"
    rescue PDF::Reader::EncryptedPDFError => e
      raise ExtractionError, "PDF is password-protected and cannot be read: #{e.message}"
    rescue StandardError => e
      raise ExtractionError, "Failed to read PDF: #{e.message}"
    end

    if text.strip.empty?
      raise ExtractionError, "No text could be extracted from the PDF. It may contain only images or scanned content."
    end

    text
  end

  private

  def safe_extract_page_text(page)
    page.text
  rescue StandardError
    ""
  end

  def pdf_content?(blob)
    blob.content_type == "application/pdf" || blob.filename.extension&.downcase == "pdf"
  end
end
