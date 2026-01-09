require "test_helper"

class TaxReturnsWorksheetTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "worksheet@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: "password123" }
  end

  test "user can view worksheet" do
    get "/tax_returns/#{@tax_return.id}/worksheet"
    assert_response :success
  end
end
