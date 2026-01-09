class BoxesController < ApplicationController
  before_action :set_tax_return

  def index
    box_values = @tax_return.box_values.includes(:box_definition).order("box_definitions.box_code")

    render json: box_values.map { |box_value| serialize_box_value(box_value) }
  end

  def update
    box_definition = BoxDefinition.find(params[:box_definition_id])
    box_value = @tax_return.box_values.find_or_initialize_by(box_definition: box_definition)

    if box_value.update(box_value_params)
      sync_fx_provenance(box_value)
      render json: { success: true, box_value: serialize_box_value(box_value) }
    else
      render json: { success: false, errors: box_value.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:id])
  end

  def box_value_params
    nested = params.fetch(:box_value, {}).permit(:value_raw, :note, :currency, :value_gbp)
    return nested if nested.present?

    params.permit(:value_raw, :note, :currency, :value_gbp)
  end

  def serialize_box_value(box_value)
    {
      id: box_value.id,
      box_definition_id: box_value.box_definition_id,
      box_code: box_value.box_definition.box_code,
      box_name: box_value.box_definition.hmrc_label,
      value_raw: box_value.value_raw,
      value_gbp: box_value.value_gbp,
      note: box_value.note,
      currency: box_value.currency,
      fx_provenance_id: box_value.fx_provenance&.id,
      updated_at: box_value.updated_at.iso8601
    }
  end

  def sync_fx_provenance(box_value)
    fx_params = params.fetch(:fx_provenance, {}).permit(
      :original_amount, :original_currency, :gbp_amount, :exchange_rate, :rate_method, :rate_period, :rate_source, :note
    )

    if fx_params.values.all?(&:blank?)
      return unless box_value.currency.present? && box_value.currency != "GBP" && box_value.value_gbp.present?

      fx_params = {
        original_amount: box_value.value_raw,
        original_currency: box_value.currency,
        gbp_amount: box_value.value_gbp
      }.compact
    end

    fx_record = box_value.fx_provenance || box_value.build_fx_provenance
    fx_record.assign_attributes(fx_params)
    fx_record.original_currency ||= box_value.currency if box_value.currency.present? && box_value.currency != "GBP"
    fx_record.original_amount ||= box_value.value_raw if box_value.value_raw.present? && box_value.currency.present? && box_value.currency != "GBP"
    fx_record.gbp_amount ||= box_value.value_gbp if box_value.value_gbp.present?
    fx_record.save!
  end
end
