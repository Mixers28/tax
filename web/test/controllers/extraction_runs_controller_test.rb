require "test_helper"

class ExtractionRunsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @other_user = User.create!(email: "other@example.com", password: "password123")

    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )

    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")
    @other_tax_return = @other_user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    @evidence = @tax_return.evidences.create!
    @evidence.file.attach(
      io: StringIO.new("PDF content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )

    @other_evidence = @other_tax_return.evidences.create!
    @other_evidence.file.attach(
      io: StringIO.new("PDF content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: user.password == "password123" ? "password123" : user.password }
  end

  test "user can create extraction run for their own evidence" do
    stub_extraction_services

    post evidence_extraction_runs_path(@evidence)

    assert_response :redirect
    assert_redirected_to evidence_path(@evidence)
    assert ExtractionRun.exists?(evidence_id: @evidence.id)
  end

  test "user cannot create extraction run for other user's evidence" do
    post evidence_extraction_runs_path(@other_evidence)

    assert_response :redirect
    assert_redirected_to root_url
    assert_equal "Access denied", flash[:alert]
  end

  test "extraction run completes successfully with valid PDF" do
    stub_extraction_services(success: true)

    post evidence_extraction_runs_path(@evidence)

    run = ExtractionRun.last
    assert_equal "completed", run.status
    assert run.prompt.present?
    assert run.response_raw.present?
    assert run.candidates.present?
  end

  test "extraction run fails gracefully when PDF extraction fails" do
    stub_extraction_services(pdf_error: true)

    post evidence_extraction_runs_path(@evidence)

    run = ExtractionRun.last
    assert_equal "failed", run.status
    assert run.error_message.present?
    assert_equal "PDF extraction failed", run.error_message
  end

  test "extraction run fails gracefully when Ollama is unavailable" do
    stub_extraction_services(ollama_error: true)

    post evidence_extraction_runs_path(@evidence)

    run = ExtractionRun.last
    assert_equal "failed", run.status
    assert run.error_message.include?("Ollama")
  end

  test "accept_candidate saves box value for current user" do
    form_def = FormDefinition.create!(code: "SA100")
    page_def = PageDefinition.create!(form_definition: form_def, page_code: "TR1")
    box_def = BoxDefinition.create!(
      page_definition: page_def,
      box_code: "1",
      instance: 1,
      label: "Test Box"
    )

    extraction_run = @evidence.extraction_runs.create!(
      status: "completed",
      model: "gemma3:1b",
      started_at: Time.current,
      finished_at: Time.current,
      candidates: [
        {
          "form" => "SA100",
          "page" => "TR1",
          "box" => "1",
          "instance" => 1,
          "value_raw" => "5000",
          "confidence" => 0.95,
          "box_definition_id" => box_def.id
        }
      ]
    )

    post accept_candidate_extraction_run_path(extraction_run, candidate_index: 0)

    assert_response :redirect
    assert_redirected_to evidence_path(@evidence)

    box_value = BoxValue.where(
      tax_return_id: @tax_return.id,
      box_definition_id: box_def.id
    ).first

    assert box_value.present?
    assert_equal "5000", box_value.value_raw
    assert box_value.note.include?("LLM extraction suggestion")
  end

  test "accept_candidate denies access for other user's evidence" do
    extraction_run = @other_evidence.extraction_runs.create!(
      status: "completed",
      model: "gemma3:1b",
      started_at: Time.current,
      finished_at: Time.current,
      candidates: []
    )

    post accept_candidate_extraction_run_path(extraction_run, candidate_index: 0)

    assert_response :redirect
    assert_redirected_to root_url
    assert_equal "Access denied", flash[:alert]
  end

  test "accept_candidate fails when candidate index is invalid" do
    extraction_run = @evidence.extraction_runs.create!(
      status: "completed",
      model: "gemma3:1b",
      started_at: Time.current,
      finished_at: Time.current,
      candidates: []
    )

    post accept_candidate_extraction_run_path(extraction_run, candidate_index: 99)

    assert_response :redirect
    assert_redirected_to evidence_path(@evidence)
    assert_equal "Candidate not found.", flash[:alert]
  end

  test "accept_candidate creates audit log" do
    form_def = FormDefinition.create!(code: "SA100")
    page_def = PageDefinition.create!(form_definition: form_def, page_code: "TR1")
    box_def = BoxDefinition.create!(
      page_definition: page_def,
      box_code: "1",
      instance: 1,
      label: "Test Box"
    )

    extraction_run = @evidence.extraction_runs.create!(
      status: "completed",
      model: "gemma3:1b",
      started_at: Time.current,
      finished_at: Time.current,
      candidates: [
        {
          "form" => "SA100",
          "page" => "TR1",
          "box" => "1",
          "instance" => 1,
          "value_raw" => "1000",
          "confidence" => 0.90,
          "box_definition_id" => box_def.id
        }
      ]
    )

    post accept_candidate_extraction_run_path(extraction_run, candidate_index: 0)

    audit_log = AuditLog.where(action: "extraction_accept").last
    assert audit_log.present?
    assert audit_log.before_state.is_a?(Hash)
    assert audit_log.after_state.is_a?(Hash)
  end

  private

  def stub_extraction_services(success: false, pdf_error: false, ollama_error: false)
    if pdf_error
      allow_any_instance_of(PdfTextExtractionService)
        .to receive(:extract)
        .and_raise(PdfTextExtractionService::ExtractionError, "PDF extraction failed")
    elsif ollama_error
      allow_any_instance_of(PdfTextExtractionService)
        .to receive(:extract)
        .and_return("Sample PDF text")

      allow_any_instance_of(OllamaExtractionService)
        .to receive(:extract_candidates)
        .and_raise(OllamaExtractionService::ExtractionError, "Failed to reach Ollama")
    elsif success || true
      allow_any_instance_of(PdfTextExtractionService)
        .to receive(:extract)
        .and_return("Sample PDF text")

      allow_any_instance_of(OllamaExtractionService)
        .to receive(:extract_candidates)
        .and_return({
          prompt: "Test prompt",
          response_raw: '{"candidates": []}',
          candidates: []
        })
    end
  end
end
