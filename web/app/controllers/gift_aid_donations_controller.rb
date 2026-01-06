class GiftAidDonationsController < ApplicationController
  before_action :set_tax_return
  before_action :set_gift_aid_donation, only: [:edit, :update, :destroy]

  def index
    @gift_aid_donations = @tax_return.income_sources
      .gift_aid_donations
      .order(created_at: :desc)
    @total_donations = @gift_aid_donations.sum(:amount_gross).to_f
  end

  def new
    @gift_aid_donation = @tax_return.income_sources.build(source_type: :gift_aid_donation)
  end

  def create
    @gift_aid_donation = @tax_return.income_sources.build(gift_aid_donation_params)
    @gift_aid_donation.source_type = :gift_aid_donation

    if @gift_aid_donation.save
      redirect_to tax_return_gift_aid_donations_path(@tax_return),
                  notice: "Gift Aid donation added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @gift_aid_donation.update(gift_aid_donation_params)
      redirect_to tax_return_gift_aid_donations_path(@tax_return),
                  notice: "Gift Aid donation updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gift_aid_donation.destroy
    redirect_to tax_return_gift_aid_donations_path(@tax_return),
                notice: "Gift Aid donation deleted successfully."
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:tax_return_id])
  end

  def set_gift_aid_donation
    @gift_aid_donation = @tax_return.income_sources.gift_aid_donations.find(params[:id])
  end

  def gift_aid_donation_params
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
