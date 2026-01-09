require "test_helper"

class BoxesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "boxes@example.com", password: "password123")
    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )
    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    form = FormDefinition.create!(code: "SA100", year: 2024)
    page = PageDefinition.create!(form_definition: form, page_code: "1")
    @box = BoxDefinition.create!(
      page_definition: page,
      box_code: "1",
      instance: 1,
      hmrc_label: "Test Box",
      data_type: "text"
    )

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: "password123" }
  end

  test "returns boxes list" do
    @tax_return.box_values.create!(box_definition: @box, value_raw: "123")

    get "/returns/#{@tax_return.id}/boxes"

    assert_response :success
    data = JSON.parse(response.body)
    assert_equal "1", data.first["box_code"]
    assert_equal "123", data.first["value_raw"]
  end

  test "updates box value with nested params" do
    patch "/returns/#{@tax_return.id}/boxes/#{@box.id}", params: { box_value: { value_raw: "456", note: "note" } }

    assert_response :success
    @tax_return.box_values.reload
    assert_equal "456", @tax_return.box_values.first.value_raw
  end

  test "updates box value with top-level params" do
    patch "/returns/#{@tax_return.id}/boxes/#{@box.id}", params: { value_raw: "789" }

    assert_response :success
    @tax_return.box_values.reload
    assert_equal "789", @tax_return.box_values.first.value_raw
  end

  test "stores fx provenance for non-GBP values" do
    patch "/returns/#{@tax_return.id}/boxes/#{@box.id}", params: {
      value_raw: "100.00",
      currency: "EUR",
      value_gbp: 86,
      fx_provenance: {
        original_amount: "100.00",
        original_currency: "EUR",
        gbp_amount: "86.00",
        exchange_rate: "0.86",
        rate_method: "HMRC average",
        rate_period: "2024-04",
        rate_source: "hmrc"
      }
    }

    assert_response :success
    box_value = @tax_return.box_values.first
    assert_equal "EUR", box_value.currency
    assert box_value.fx_provenance.present?
    assert_in_delta 0.86, box_value.fx_provenance.exchange_rate.to_f, 0.0001
  end
end
