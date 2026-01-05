class ValidationsController < ApplicationController
  before_action :set_tax_return

  def index
    @validation_results = ValidationService.new(@tax_return).generate_report
    @box_validations = @tax_return.box_values.includes(:box_validations, :validation_rules).map do |bv|
      {
        box_value: bv,
        validations: bv.box_validations.active.includes(:validation_rule)
      }
    end
  end

  def run_validation
    validation_service = ValidationService.new(@tax_return)
    results = validation_service.validate_all

    redirect_to tax_return_validations_path(@tax_return), notice: "Validations completed successfully."
  end

  private

  def set_tax_return
    @tax_return = current_user.tax_returns.find(params[:tax_return_id])
  end
end
