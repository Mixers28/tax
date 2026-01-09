class FieldValuesController < ApplicationController
  before_action :set_tax_return
  before_action :set_field_value, only: [:update]

  def index
    template_profile = @tax_return.return_workspace&.template_profile || TemplateProfile.first
    ReturnWorkspaceGenerator.call(tax_return: @tax_return, template_profile: template_profile) if template_profile

    @template_profile = template_profile
    @field_values = @tax_return.return_workspace&.field_values&.includes(:template_field, :evidence_links, :fx_provenance) || []
    @evidences = @tax_return.evidences.order(created_at: :desc)
  end

  def update
    if @field_value.update(field_value_params)
      sync_confirmation
      sync_evidence_link
      sync_fx_provenance
      redirect_to tax_return_field_values_path(@tax_return), notice: "Field updated."
    else
      redirect_to tax_return_field_values_path(@tax_return), alert: @field_value.errors.full_messages.join(", ")
    end
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:tax_return_id])
  end

  def set_field_value
    return_workspace = @tax_return.return_workspace
    unless return_workspace
      redirect_to tax_return_field_values_path(@tax_return), alert: "No workspace found for this return."
      return
    end

    @field_value = return_workspace.field_values.find(params[:id])
  end

  def field_value_params
    params.require(:field_value).permit(:value_raw, :note)
  end

  def sync_confirmation
    confirmed = params.dig(:field_value, :confirmed) == "1"
    @field_value.update!(confirmed_at: confirmed ? Time.current : nil)
  end

  def sync_evidence_link
    evidence_id = params.dig(:field_value, :evidence_id)
    return if evidence_id.blank?

    EvidenceLink.find_or_create_by!(evidence_id: evidence_id, linkable: @field_value)
  end

  def sync_fx_provenance
    fx_params = params.fetch(:fx_provenance, {}).permit(
      :original_amount, :original_currency, :gbp_amount, :exchange_rate, :rate_method, :rate_period, :rate_source, :note
    )
    return if fx_params.values.all?(&:blank?)

    fx_record = @field_value.fx_provenance || @field_value.build_fx_provenance
    fx_record.update!(fx_params)
  end
end
