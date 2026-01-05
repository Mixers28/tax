class TaxReturnsController < ApplicationController
  before_action :set_tax_return, only: [:show, :update_calculator_settings]

  def index
    @tax_returns = current_user.tax_returns.includes(:tax_year).order(created_at: :desc)
  end

  def create
    tax_year = TaxYear.find_or_create_by!(label: "SA100 2025 / 2024-25") do |record|
      record.start_date = Date.new(2024, 4, 6)
      record.end_date = Date.new(2025, 4, 5)
    end

    tax_return = current_user.tax_returns.create!(tax_year: tax_year, status: "draft")

    redirect_to new_evidence_path(tax_return_id: tax_return.id), notice: "Draft tax return created."
  end

  def show
  end

  def update_calculator_settings
    enabled_calculators = params[:calculators] || []
    @tax_return.update!(enabled_calculators: enabled_calculators.join(","))

    redirect_to tax_return_path(@tax_return), notice: "Calculator settings updated successfully."
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:id])
  end
end
