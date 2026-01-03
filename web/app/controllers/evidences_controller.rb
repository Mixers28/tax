class EvidencesController < ApplicationController
  def new
    @evidence = Evidence.new
  end

  def create
    @evidence = Evidence.new(evidence_params)
    if @evidence.save
      redirect_to evidence_path(@evidence), notice: "Evidence uploaded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @evidence = Evidence.find(params[:id])
  end

  private

  def evidence_params
    params.require(:evidence).permit(:tax_return_id, :file)
  end
end
