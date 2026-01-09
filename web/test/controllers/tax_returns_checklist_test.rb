require "test_helper"

class TaxReturnsChecklistTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "checklist@example.com", password: "password123")
    @other_user = User.create!(email: "other-checklist@example.com", password: "password123")

    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )

    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")
    @other_tax_return = @other_user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    form = FormDefinition.create!(code: "SA100")
    page = PageDefinition.create!(form_definition: form, page_code: "1")
    box = BoxDefinition.create!(
      page_definition: page,
      box_code: "1",
      instance: 1,
      hmrc_label: "Test Box",
      data_type: "text"
    )

    profile = TemplateProfile.create!(name: "Default Profile")
    TemplateField.create!(
      template_profile: profile,
      box_definition: box,
      data_type: "text",
      required: true
    )

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: "password123" }
  end

  test "user can view checklist" do
    get "/tax_returns/#{@tax_return.id}/checklist"
    assert_response :success
    assert @tax_return.reload.return_workspace.present?
  end

  test "user cannot view other user's checklist" do
    get "/tax_returns/#{@other_tax_return.id}/checklist"
    assert_response :redirect
  end
end
