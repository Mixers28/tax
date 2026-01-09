class ReturnWorkspaceGenerator
  def self.call(tax_return:, template_profile:)
    workspace = ReturnWorkspace.find_or_create_by!(
      tax_return: tax_return,
      template_profile: template_profile
    )

    template_profile.template_fields.find_each do |template_field|
      workspace.field_values.find_or_create_by!(template_field: template_field)
    end

    workspace
  end
end
