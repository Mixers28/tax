class CalculationsController < ApplicationController
  before_action :set_tax_return

  def index
    @calculations = @tax_return.tax_calculations.order(created_at: :desc)
  end

  def calculate_ftcr
    result = Calculators::FtcrCalculator.new(@tax_return).calculate

    if result[:success]
      create_calculation_record(result)
      redirect_to tax_return_calculations_path(@tax_return), notice: "FTCR calculation completed. Result: £#{result[:output_value]}"
    else
      redirect_to tax_return_calculations_path(@tax_return), alert: "Calculation failed: #{result[:error]}"
    end
  end

  def calculate_gift_aid
    result = Calculators::GiftAidCalculator.new(@tax_return).calculate

    if result[:success]
      create_calculation_record(result)
      redirect_to tax_return_calculations_path(@tax_return), notice: "Gift Aid calculation completed. Result: £#{result[:output_value]}"
    else
      redirect_to tax_return_calculations_path(@tax_return), alert: "Calculation failed: #{result[:error]}"
    end
  end

  def calculate_hicbc
    result = Calculators::HicbcCalculator.new(@tax_return).calculate

    if result[:success]
      create_calculation_record(result)
      redirect_to tax_return_calculations_path(@tax_return), notice: "HICBC calculation completed. Result: £#{result[:output_value]}"
    else
      redirect_to tax_return_calculations_path(@tax_return), alert: "Calculation failed: #{result[:error]}"
    end
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:tax_return_id])
  end

  def create_calculation_record(result)
    TaxCalculation.create!(
      tax_return: @tax_return,
      calculation_type: result[:calculation_type],
      input_box_ids: result[:input_values].keys.map(&:to_s),
      result_value_gbp: result[:output_value],
      confidence_score: result[:confidence],
      calculation_steps: result[:calculation_steps],
      input_values: result[:input_values]
    )
  end
end
