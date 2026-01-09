class TemplateFieldsController < ApplicationController
  before_action :set_template_profile
  before_action :set_template_field, only: [:update, :destroy]

  def create
    return unless @template_profile

    template_field = @template_profile.template_fields.build(template_field_params)

    if template_field.save
      redirect_to template_profile_path, notice: "Template field added."
    else
      redirect_to template_profile_path, alert: template_field.errors.full_messages.join(", ")
    end
  end

  def update
    return unless @template_profile

    if @template_field.update(template_field_params)
      redirect_to template_profile_path, notice: "Template field updated."
    else
      redirect_to template_profile_path, alert: @template_field.errors.full_messages.join(", ")
    end
  end

  def destroy
    return unless @template_profile

    @template_field.destroy
    redirect_to template_profile_path, notice: "Template field removed."
  end

  private

  def set_template_profile
    @template_profile = TemplateProfile.first
    return if @template_profile

    redirect_to new_template_profile_path, notice: "Create a template profile to begin."
  end

  def set_template_field
    @template_field = @template_profile.template_fields.find(params[:id])
  end

  def template_field_params
    params.require(:template_field).permit(:box_definition_id, :label, :data_type, :required, :position)
  end
end
