class TaxReturnsController < ApplicationController
  before_action :set_tax_return, only: [:show, :checklist, :worksheet, :update_calculator_settings, :toggle_blind_person]

  def index
    @tax_returns = current_user.tax_returns.includes(:tax_year).order(created_at: :desc)
  end

  def create
    tax_year = TaxYear.find_or_create_by!(label: "SA100 2025 / 2024-25") do |record|
      record.start_date = Date.new(2024, 4, 6)
      record.end_date = Date.new(2025, 4, 5)
    end

    tax_return = current_user.tax_returns.create!(tax_year: tax_year, status: "draft")
    template_profile = TemplateProfile.first
    ReturnWorkspaceGenerator.call(tax_return: tax_return, template_profile: template_profile) if template_profile

    redirect_to new_evidence_path(tax_return_id: tax_return.id), notice: "Draft tax return created."
  end

  def show
    @template_profile = TemplateProfile.first
  end

  def checklist
    template_profile = @tax_return.return_workspace&.template_profile || TemplateProfile.first
    ReturnWorkspaceGenerator.call(tax_return: @tax_return, template_profile: template_profile) if template_profile

    @template_profile = template_profile
    @checklist = TemplateChecklistService.new(@tax_return).call
  end

  def worksheet
    template_profile = @tax_return.return_workspace&.template_profile || TemplateProfile.first
    ReturnWorkspaceGenerator.call(tax_return: @tax_return, template_profile: template_profile) if template_profile

    @worksheet = WorksheetDataService.new(@tax_return).call
  end

  def update_calculator_settings
    enabled_calculators = params[:calculators] || []
    @tax_return.update!(enabled_calculators: enabled_calculators.join(","))

    redirect_to tax_return_path(@tax_return), notice: "Calculator settings updated successfully."
  end

  def toggle_blind_person
    @tax_return.update!(is_blind_person: !@tax_return.is_blind_person)
    redirect_to tax_return_path(@tax_return), notice: "Blind Person status updated."
  end

  # Phase 5d: Toggle Trading Allowance
  def toggle_trading_allowance
    @tax_return.update!(uses_trading_allowance: !@tax_return.uses_trading_allowance)
    redirect_to tax_return_path(@tax_return), notice: "Trading Allowance #{@tax_return.uses_trading_allowance ? 'enabled' : 'disabled'}."
  end

  # Phase 5d: Update Marriage Allowance
  def update_marriage_allowance
    if @tax_return.update(marriage_allowance_params)
      redirect_to tax_return_path(@tax_return), notice: "Marriage Allowance updated."
    else
      redirect_to tax_return_path(@tax_return), alert: "Error: #{@tax_return.errors.full_messages.join(', ')}"
    end
  end

  # Phase 5d: Update Married Couple's Allowance
  def update_married_couples_allowance
    if @tax_return.update(married_couples_allowance_params)
      redirect_to tax_return_path(@tax_return), notice: "Married Couple's Allowance updated."
    else
      redirect_to tax_return_path(@tax_return), alert: "Error: #{@tax_return.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:id])
  end

  def marriage_allowance_params
    params.require(:tax_return).permit(:claims_marriage_allowance, :marriage_allowance_role)
  end

  def married_couples_allowance_params
    params.require(:tax_return).permit(:claims_married_couples_allowance, :spouse_dob)
  end
end
