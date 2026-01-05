class ExtractionRunsController < ApplicationController
  before_action :authorize_evidence, only: [:create, :accept_candidate]

  def create
    evidence = @evidence

    run = evidence.extraction_runs.create!(
      status: "pending",
      model: ENV.fetch("OLLAMA_MODEL", OllamaExtractionService::DEFAULT_MODEL),
      started_at: Time.current
    )

    begin
      unless evidence.file.attached?
        raise PdfTextExtractionService::ExtractionError, "Evidence file is missing"
      end

      ollama_service = OllamaExtractionService.new
      unless ollama_service.available?
        raise OllamaExtractionService::ExtractionError, "Ollama service is not available. Please ensure it is running on #{ollama_service.instance_variable_get(:@url)}"
      end

      text = PdfTextExtractionService.new(evidence.file.blob).extract
      result = ollama_service.extract_candidates(text)
      candidates = resolve_candidates(result[:candidates])

      run.update!(
        status: "completed",
        prompt: result[:prompt],
        response_raw: result[:response_raw],
        candidates: candidates,
        finished_at: Time.current
      )

      AuditLog.create!(
        action: "extraction_suggested",
        object_ref: "Evidence:#{evidence.id}",
        after_state: { extraction_run_id: run.id, candidates: candidates.size },
        logged_at: Time.current
      )
    rescue PdfTextExtractionService::ExtractionError, OllamaExtractionService::ExtractionError => e
      run.update!(status: "failed", error_message: e.message, finished_at: Time.current)
      flash[:alert] = "Extraction failed: #{e.message}"
    end

    redirect_to evidence_path(evidence)
  end

  def accept_candidate
    run = ExtractionRun.find(params[:id])
    evidence = run.evidence
    candidates = run.candidates || []
    candidate = candidates.fetch(params[:candidate_index].to_i)
    box_definition_id = candidate["box_definition_id"]

    unless box_definition_id
      redirect_to evidence_path(evidence), alert: "Candidate does not match a known box." and return
    end

    tax_return = evidence.tax_return
    box_value = BoxValue.find_or_initialize_by(
      tax_return_id: tax_return.id,
      box_definition_id: box_definition_id
    )

    before_state = box_value.attributes.slice("value_raw", "note")

    box_value.value_raw = candidate["value_raw"].to_s
    box_value.note = build_note(candidate)
    box_value.save!

    AuditLog.create!(
      action: "extraction_accept",
      object_ref: "BoxValue:#{box_value.id}",
      before_state: before_state,
      after_state: box_value.attributes.slice("value_raw", "note"),
      logged_at: Time.current
    )

    redirect_to evidence_path(run.evidence), notice: "Candidate accepted."
  rescue IndexError
    redirect_to evidence_path(run.evidence), alert: "Candidate not found."
  end

  private

  def authorize_evidence
    @evidence = Evidence.find(params[:evidence_id] || ExtractionRun.find(params[:id]).evidence_id)
    unless @evidence.tax_return.user_id == current_user.id
      redirect_to root_url, alert: "Access denied"
    end
  end

  def resolve_candidates(candidates)
    candidates.map do |candidate|
      normalized = candidate.transform_keys(&:to_s)
      normalized["box_definition_id"] = resolve_box_definition_id(normalized)
      normalized
    end
  end

  def resolve_box_definition_id(candidate)
    form_code = candidate["form"]
    page_code = candidate["page"]
    box_code = candidate["box"]
    instance = candidate["instance"].to_i
    instance = 1 if instance.zero?

    return nil if form_code.blank? || page_code.blank? || box_code.blank?

    form_definition = FormDefinition.find_by(code: form_code)
    return nil unless form_definition

    page_definition = PageDefinition.find_by(form_definition_id: form_definition.id, page_code: page_code)
    return nil unless page_definition

    box_definition = BoxDefinition.find_by(
      page_definition_id: page_definition.id,
      box_code: box_code.to_s,
      instance: instance
    )

    box_definition&.id
  end

  def build_note(candidate)
    note_parts = ["LLM extraction suggestion"]
    note_parts << candidate["note"] if candidate["note"].present?
    note_parts.join(" - ")
  end
end
