require "test_helper"

class FieldValuesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "fields@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    form = FormDefinition.create!(code: "SA100", year: 2024)
    page = PageDefinition.create!(form_definition: form, page_code: "1")
    box = BoxDefinition.create!(
      page_definition: page,
      box_code: "1",
      instance: 1,
      hmrc_label: "Test Box",
      data_type: "text"
    )
    profile = TemplateProfile.create!(name: "Default Profile")
    field = TemplateField.create!(
      template_profile: profile,
      box_definition: box,
      data_type: "text",
      required: true
    )
    ReturnWorkspaceGenerator.call(tax_return: @tax_return, template_profile: profile)
    @field_value = @tax_return.return_workspace.field_values.find_by!(template_field: field)

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: "password123" }
  end

  test "user can view field values" do
    get "/tax_returns/#{@tax_return.id}/field_values"
    assert_response :success
  end

  test "user can update field value" do
    patch "/tax_returns/#{@tax_return.id}/field_values/#{@field_value.id}", params: {
      field_value: { value_raw: "123", note: "Test note", confirmed: "1" }
    }
    assert_response :redirect
    @field_value.reload
    assert_equal "123", @field_value.value_raw
    assert_equal "Test note", @field_value.note
    assert @field_value.confirmed_at.present?
  end
end
