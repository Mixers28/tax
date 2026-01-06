class PensionContributionsController < ApplicationController
  before_action :set_tax_return
  before_action :set_pension_contribution, only: [:edit, :update, :destroy]

  def index
    @pension_contributions = @tax_return.income_sources
      .pension_contributions
      .order(created_at: :desc)
    @total_contributions = @pension_contributions.sum(:amount_gross).to_f
  end

  def new
    @pension_contribution = @tax_return.income_sources.build(source_type: :pension_contribution)
  end

  def create
    @pension_contribution = @tax_return.income_sources.build(pension_contribution_params)
    @pension_contribution.source_type = :pension_contribution

    if @pension_contribution.save
      redirect_to tax_return_pension_contributions_path(@tax_return),
                  notice: "Pension contribution added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @pension_contribution.update(pension_contribution_params)
      redirect_to tax_return_pension_contributions_path(@tax_return),
                  notice: "Pension contribution updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pension_contribution.destroy
    redirect_to tax_return_pension_contributions_path(@tax_return),
                notice: "Pension contribution deleted successfully."
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:tax_return_id])
  end

  def set_pension_contribution
    @pension_contribution = @tax_return.income_sources.pension_contributions.find(params[:id])
  end

  def pension_contribution_params
    source_params = params.require(:income_source).permit(
      :amount_gross, :description, :currency, :exchange_rate
    )

    # Handle currency conversion if needed
    if source_params[:currency].present? && source_params[:currency] != 'GBP'
      # Get exchange rate (from form or from environment)
      rate = source_params[:exchange_rate].present? ? source_params[:exchange_rate].to_f : ExchangeRateConfig.get_rate(source_params[:currency])

      # Convert amounts to GBP
      source_params[:amount_gross] = ExchangeRateConfig.convert(source_params[:amount_gross], source_params[:currency])

      # Store the exchange rate used for audit trail
      source_params[:exchange_rate] = rate

      # After conversion, store as GBP
      source_params[:currency] = 'GBP'
    else
      source_params[:currency] = 'GBP'
      source_params[:exchange_rate] = 1.0
    end

    source_params
  end
end
