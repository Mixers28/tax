class EvidencesController < ApplicationController
  before_action :set_evidence, only: [:show]
  before_action :validate_tax_return, only: [:new, :create]

  def new
    @evidence = Evidence.new(tax_return_id: params[:tax_return_id])
    @tax_returns = current_user.tax_returns.includes(:tax_year).order(created_at: :desc)
  end

  def create
    files = params[:evidence][:file]
    files = [files] unless files.is_a?(Array)

    saved_count = 0
    error_count = 0

    files.each do |file|
      evidence = Evidence.new(
        tax_return_id: evidence_params[:tax_return_id],
        evidence_type: evidence_params[:evidence_type]
      )
      evidence.file.attach(file)

      if evidence.save
        saved_count += 1
      else
        error_count += 1
      end
    end

    if error_count == 0
      redirect_to new_evidence_path(tax_return_id: evidence_params[:tax_return_id]),
                  notice: "#{saved_count} file(s) uploaded successfully."
    elsif saved_count > 0
      redirect_to new_evidence_path(tax_return_id: evidence_params[:tax_return_id]),
                  alert: "#{saved_count} file(s) uploaded, but #{error_count} failed."
    else
      @evidence = Evidence.new
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @extraction_runs = @evidence.extraction_runs
  end

  private

  def set_evidence
    @evidence = Evidence.find(params[:id])
    unless @evidence.tax_return.user_id == current_user.id
      redirect_to root_url, alert: "Access denied"
    end
  end

  def validate_tax_return
    unless params[:tax_return_id].blank?
      tax_return = current_user.tax_returns.find_by(id: params[:tax_return_id])
      redirect_to root_url, alert: "Tax return not found" unless tax_return
    end
  end

  def evidence_params
    params.require(:evidence).permit(:tax_return_id, :evidence_type, file: [])
  end
end
