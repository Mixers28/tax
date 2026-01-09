class TemplateProfilesController < ApplicationController
  before_action :set_template_profile, only: [:show, :update]

  def show
    unless @template_profile
      redirect_to new_template_profile_path, notice: "Create a template profile to begin."
      return
    end

    @template_fields = @template_profile.template_fields
      .includes(box_definition: { page_definition: :form_definition })
      .order(:position, :id)
    @template_field = @template_profile.template_fields.build
    @box_definitions = BoxDefinition.includes(page_definition: :form_definition).order(:box_code, :instance)
  end

  def new
    @template_profile = TemplateProfile.new
  end

  def create
    @template_profile = TemplateProfile.new(template_profile_params)

    if @template_profile.save
      redirect_to template_profile_path, notice: "Template profile created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless @template_profile
      redirect_to new_template_profile_path, notice: "Create a template profile to begin."
      return
    end

    if @template_profile.update(template_profile_params)
      redirect_to template_profile_path, notice: "Template profile updated."
    else
      @template_fields = @template_profile.template_fields
        .includes(box_definition: { page_definition: :form_definition })
        .order(:position, :id)
      @template_field = @template_profile.template_fields.build
      @box_definitions = BoxDefinition.includes(page_definition: :form_definition).order(:box_code, :instance)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_template_profile
    @template_profile = TemplateProfile.first
  end

  def template_profile_params
    params.require(:template_profile).permit(:name, :description)
  end
end
