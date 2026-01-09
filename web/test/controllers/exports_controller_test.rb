require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @other_user = User.create!(email: "other@example.com", password: "password123")

    @tax_year = TaxYear.create!(
      label: "2024-25",
      start_date: Date.new(2024, 4, 6),
      end_date: Date.new(2025, 4, 5)
    )

    @tax_return = @user.tax_returns.create!(tax_year: @tax_year, status: "draft")
    @other_tax_return = @other_user.tax_returns.create!(tax_year: @tax_year, status: "draft")

    # Create form structure
    @form = FormDefinition.create!(code: "SA100")
    @page = PageDefinition.create!(form_definition: @form, page_code: "1")
    @box = BoxDefinition.create!(
      page_definition: @page,
      box_code: "1",
      instance: 1,
      label: "Test"
    )

    @tax_return.box_values.create!(box_definition: @box, value_raw: "5000")

    login_as(@user)
  end

  def login_as(user)
    post "/login", params: { email: user.email, password: user.password == "password123" ? "password123" : user.password }
  end

  test "user can view their exports" do
    export = @tax_return.exports.create!(
      user: @user,
      format: "pdf",
      exported_at: Time.current
    )

    get "/tax_returns/#{@tax_return.id}/exports"
    assert_response :success
  end

  test "user cannot view other user's exports" do
    get "/tax_returns/#{@other_tax_return.id}/exports"
    assert_response :redirect
  end

  test "create export with pdf format" do
    stub_export_services

    post "/tax_returns/#{@tax_return.id}/exports", params: { format: "pdf" }

    assert_response :redirect
    assert Export.where(tax_return: @tax_return, format: "pdf").exists?
  end

  test "create export with both formats" do
    stub_export_services

    post "/tax_returns/#{@tax_return.id}/exports", params: { format: "both" }

    assert_response :redirect
    assert Export.where(tax_return: @tax_return, format: "both").exists?
  end

  test "view export details" do
    export = create_test_export

    get "/tax_returns/#{@tax_return.id}/exports/#{export.id}"
    assert_response :success
  end

  test "download pdf export" do
    export = create_test_export_with_file("pdf")

    get "/tax_returns/#{@tax_return.id}/exports/#{export.id}/download_pdf"

    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "download json export" do
    export = create_test_export_with_file("json")

    get "/tax_returns/#{@tax_return.id}/exports/#{export.id}/download_json"

    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "cannot download non-existent export" do
    get "/tax_returns/#{@tax_return.id}/exports/999/download_pdf"
    assert_response :not_found
  end

  test "user cannot access other user's export" do
    export = @other_tax_return.exports.create!(
      user: @other_user,
      format: "pdf",
      exported_at: Time.current
    )

    get "/tax_returns/#{@other_tax_return.id}/exports/#{export.id}"
    assert_response :redirect
  end

  private

  def create_test_export
    @tax_return.exports.create!(
      user: @user,
      format: "both",
      exported_at: Time.current,
      export_snapshot: [{ box_code: "1", value: "5000" }],
      validation_state: {}
    )
  end

  def create_test_export_with_file(format)
    export = @tax_return.exports.create!(
      user: @user,
      format: format,
      exported_at: Time.current,
      export_snapshot: [],
      validation_state: {}
    )

    if format == "pdf"
      storage_dir = Rails.root.join("storage", "exports", @tax_return.id.to_s)
      FileUtils.mkdir_p(storage_dir)
      file_path = storage_dir.join("test.pdf")
      File.write(file_path, "PDF content")
      export.update!(file_path: file_path.to_s)
    elsif format == "json"
      storage_dir = Rails.root.join("storage", "exports", @tax_return.id.to_s)
      FileUtils.mkdir_p(storage_dir)
      file_path = storage_dir.join("test.json")
      File.write(file_path, JSON.generate({ test: "data" }))
      export.update!(json_path: file_path.to_s)
    end

    export
  end

  def stub_export_services
    allow_any_instance_of(ExportService).to receive(:generate!).and_call_original
    allow_any_instance_of(PDFExportService).to receive(:generate).and_return("/tmp/test.pdf")
    allow_any_instance_of(JsonExportService).to receive(:generate).and_return("/tmp/test.json")
  end
end
