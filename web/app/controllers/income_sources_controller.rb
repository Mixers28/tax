class IncomeSourcesController < ApplicationController
  before_action :set_tax_return
  before_action :set_income_source, only: [:edit, :update, :destroy]

  def index
    @income_sources = @tax_return.income_sources.order(created_at: :desc)
  end

  def new
    @income_source = @tax_return.income_sources.build
  end

  def create
    @income_source = @tax_return.income_sources.build(income_source_params)

    if @income_source.save
      redirect_to tax_return_income_sources_path(@tax_return),
                  notice: "Income source added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @income_source.update(income_source_params)
      redirect_to tax_return_income_sources_path(@tax_return),
                  notice: "Income source updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @income_source.destroy
    redirect_to tax_return_income_sources_path(@tax_return),
                notice: "Income source deleted successfully."
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:tax_return_id])
  end

  def set_income_source
    @income_source = @tax_return.income_sources.find(params[:id])
  end

  def income_source_params
    source_params = params.require(:income_source).permit(
      :source_type, :amount_gross, :amount_tax_taken, :description, :currency, :exchange_rate
    )

    # Handle currency conversion if needed
    if source_params[:currency].present? && source_params[:currency] != 'GBP'
      # Get exchange rate (from form or from environment)
      rate = source_params[:exchange_rate].present? ? source_params[:exchange_rate].to_f : ExchangeRateConfig.get_rate(source_params[:currency])

      # Convert amounts to GBP
      source_params[:amount_gross] = ExchangeRateConfig.convert(source_params[:amount_gross], source_params[:currency])
      source_params[:amount_tax_taken] = ExchangeRateConfig.convert(source_params[:amount_tax_taken], source_params[:currency])

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
