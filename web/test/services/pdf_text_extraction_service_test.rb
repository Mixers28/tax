require "test_helper"

class PdfTextExtractionServiceTest < ActiveSupport::TestCase
  def setup
    @service_class = PdfTextExtractionService
  end

  test "extracts text from valid PDF blob" do
    pdf_blob = create_test_pdf_blob("sample.pdf", "This is test PDF content")
    service = @service_class.new(pdf_blob)

    extracted_text = service.extract

    assert extracted_text.is_a?(String)
    assert extracted_text.include?("test PDF content")
  end

  test "raises error when blob is nil" do
    service = @service_class.new(nil)

    error = assert_raises(PdfTextExtractionService::ExtractionError) { service.extract }
    assert_equal "Evidence file is missing", error.message
  end

  test "raises error when file is not a PDF" do
    text_blob = create_text_blob("test.txt", "This is plain text")
    service = @service_class.new(text_blob)

    error = assert_raises(PdfTextExtractionService::ExtractionError) { service.extract }
    assert_equal "Evidence file is not a PDF", error.message
  end

  test "raises error when PDF has no extractable text" do
    # Create an empty PDF blob
    empty_pdf_blob = create_test_pdf_blob("empty.pdf", "")
    service = @service_class.new(empty_pdf_blob)

    error = assert_raises(PdfTextExtractionService::ExtractionError) { service.extract }
    assert_equal "No text extracted from PDF", error.message
  end

  test "handles malformed PDF gracefully" do
    # Create a malformed PDF blob
    malformed_blob = create_malformed_pdf_blob("malformed.pdf")
    service = @service_class.new(malformed_blob)

    assert_raises(PdfTextExtractionService::ExtractionError) { service.extract }
  end

  private

  def create_test_pdf_blob(filename, content)
    # Simple PDF creation with text content
    require "tempfile"

    # Use a minimal valid PDF structure
    pdf_content = if content.empty?
      "%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n3 0 obj\n<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 4 0 R >> >> /MediaBox [0 0 612 792] /Contents 5 0 R >>\nendobj\n4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n5 0 obj\n<< /Length 0 >>\nstream\nendstream\nendobj\nxref\n0 6\n0000000000 65535 f\n0000000009 00000 n\n0000000056 00000 n\n0000000115 00000 n\n0000000214 00000 n\n0000000303 00000 n\ntrailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n354\n%%EOF"
    else
      # Create a basic valid PDF with text
      "%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n3 0 obj\n<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 4 0 R >> >> /MediaBox [0 0 612 792] /Contents 5 0 R >>\nendobj\n4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n5 0 obj\n<< /Length #{content.bytesize + 50} >>\nstream\nBT\n/F1 12 Tf\n50 700 Td\n(#{content}) Tj\nET\nendstream\nendobj\nxref\n0 6\n0000000000 65535 f\n0000000009 00000 n\n0000000056 00000 n\n0000000115 00000 n\n0000000214 00000 n\n0000000303 00000 n\ntrailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n450\n%%EOF"
    end

    blob = create_active_storage_blob(
      filename: filename,
      content_type: "application/pdf",
      data: pdf_content
    )
    blob
  end

  def create_text_blob(filename, content)
    blob = create_active_storage_blob(
      filename: filename,
      content_type: "text/plain",
      data: content
    )
    blob
  end

  def create_malformed_pdf_blob(filename)
    blob = create_active_storage_blob(
      filename: filename,
      content_type: "application/pdf",
      data: "This is not a valid PDF\x00\x01\x02"
    )
    blob
  end

  def create_active_storage_blob(filename:, content_type:, data:)
    blob = ActiveStorage::Blob.new(filename: filename, content_type: content_type)
    blob.upload(StringIO.new(data))
    blob
  end
end
