# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_06_012931) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action", null: false
    t.string "actor"
    t.json "after_state"
    t.json "before_state"
    t.datetime "created_at", null: false
    t.datetime "logged_at", null: false
    t.string "object_ref", null: false
    t.datetime "updated_at", null: false
    t.index ["logged_at"], name: "index_audit_logs_on_logged_at"
  end

  create_table "box_definitions", force: :cascade do |t|
    t.string "box_code", null: false
    t.json "constraints"
    t.datetime "created_at", null: false
    t.string "data_type", default: "text", null: false
    t.string "hmrc_label", null: false
    t.integer "instance", default: 1, null: false
    t.integer "page_definition_id", null: false
    t.string "required_rule"
    t.datetime "updated_at", null: false
    t.index ["page_definition_id", "box_code", "instance"], name: "index_box_defs_on_page_and_code_and_instance", unique: true
    t.index ["page_definition_id"], name: "index_box_definitions_on_page_definition_id"
  end

  create_table "box_validations", force: :cascade do |t|
    t.integer "box_value_id", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "expires_at"
    t.boolean "is_valid", default: false
    t.datetime "updated_at", null: false
    t.datetime "validated_at"
    t.integer "validation_rule_id", null: false
    t.text "warning_message"
    t.index ["box_value_id", "validation_rule_id"], name: "index_box_validations_on_box_value_id_and_validation_rule_id", unique: true
    t.index ["box_value_id"], name: "index_box_validations_on_box_value_id"
    t.index ["validated_at"], name: "index_box_validations_on_validated_at"
    t.index ["validation_rule_id"], name: "index_box_validations_on_validation_rule_id"
  end

  create_table "box_values", force: :cascade do |t|
    t.integer "box_definition_id", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "note"
    t.integer "scenario_id"
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.integer "value_gbp"
    t.text "value_raw"
    t.index ["box_definition_id"], name: "index_box_values_on_box_definition_id"
    t.index ["scenario_id"], name: "index_box_values_on_scenario_id"
    t.index ["tax_return_id", "box_definition_id"], name: "index_box_values_on_tax_return_id_and_box_definition_id", unique: true
    t.index ["tax_return_id"], name: "index_box_values_on_tax_return_id"
  end

  create_table "evidence_box_values", force: :cascade do |t|
    t.integer "box_value_id", null: false
    t.datetime "created_at", null: false
    t.integer "evidence_id", null: false
    t.datetime "updated_at", null: false
    t.index ["box_value_id"], name: "index_evidence_box_values_on_box_value_id"
    t.index ["evidence_id", "box_value_id"], name: "index_evidence_box_values_on_evidence_id_and_box_value_id", unique: true
    t.index ["evidence_id"], name: "index_evidence_box_values_on_evidence_id"
  end

  create_table "evidences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "evidence_type", default: "supporting_document"
    t.text "filename", null: false
    t.text "mime"
    t.text "sha256"
    t.json "tags"
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.index ["evidence_type"], name: "index_evidences_on_evidence_type"
    t.index ["tax_return_id"], name: "index_evidences_on_tax_return_id"
  end

  create_table "export_evidences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "evidence_id", null: false
    t.integer "export_id", null: false
    t.json "referenced_in_values"
    t.datetime "updated_at", null: false
    t.index ["evidence_id"], name: "index_export_evidences_on_evidence_id"
    t.index ["export_id", "evidence_id"], name: "index_export_evidences_on_export_id_and_evidence_id", unique: true
    t.index ["export_id"], name: "index_export_evidences_on_export_id"
  end

  create_table "exports", force: :cascade do |t|
    t.json "calculation_results"
    t.datetime "created_at", null: false
    t.json "export_snapshot"
    t.datetime "exported_at"
    t.string "file_hash"
    t.string "file_path"
    t.integer "file_size"
    t.string "format", null: false
    t.string "json_path"
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.json "validation_state"
    t.index ["exported_at"], name: "index_exports_on_exported_at"
    t.index ["tax_return_id", "created_at"], name: "index_exports_on_tax_return_id_and_created_at"
    t.index ["tax_return_id"], name: "index_exports_on_tax_return_id"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "extraction_runs", force: :cascade do |t|
    t.json "candidates"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.integer "evidence_id", null: false
    t.datetime "finished_at"
    t.string "model", null: false
    t.text "prompt"
    t.text "response_raw"
    t.datetime "started_at", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["evidence_id"], name: "index_extraction_runs_on_evidence_id"
    t.index ["status"], name: "index_extraction_runs_on_status"
  end

  create_table "form_definitions", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "version_meta"
    t.integer "year", null: false
    t.index ["code", "year"], name: "index_form_definitions_on_code_and_year", unique: true
  end

  create_table "income_sources", force: :cascade do |t|
    t.decimal "amount_gross", precision: 12, scale: 2, null: false
    t.decimal "amount_tax_taken", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "GBP"
    t.string "description"
    t.decimal "exchange_rate", precision: 10, scale: 6, default: "1.0"
    t.boolean "is_eligible_for_pa", default: true
    t.boolean "is_eligible_for_relief", default: false
    t.integer "source_type", default: 0, null: false
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type"], name: "index_income_sources_on_source_type"
    t.index ["tax_return_id"], name: "index_income_sources_on_tax_return_id"
  end

  create_table "page_definitions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "form_definition_id", null: false
    t.string "page_code", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["form_definition_id", "page_code"], name: "index_page_definitions_on_form_definition_id_and_page_code", unique: true
    t.index ["form_definition_id"], name: "index_page_definitions_on_form_definition_id"
  end

  create_table "tax_bands", force: :cascade do |t|
    t.decimal "additional_rate_percentage", precision: 5, scale: 2, null: false
    t.decimal "basic_rate_limit", precision: 12, scale: 2, null: false
    t.decimal "basic_rate_percentage", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.decimal "higher_rate_limit", precision: 12, scale: 2, null: false
    t.decimal "higher_rate_percentage", precision: 5, scale: 2, null: false
    t.decimal "ni_basic_percentage", precision: 5, scale: 2, null: false
    t.decimal "ni_higher_percentage", precision: 5, scale: 2, null: false
    t.decimal "ni_lower_threshold", precision: 12, scale: 2, null: false
    t.decimal "ni_upper_threshold", precision: 12, scale: 2, null: false
    t.decimal "pa_amount", precision: 12, scale: 2, null: false
    t.integer "tax_year", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_year"], name: "index_tax_bands_on_tax_year", unique: true
  end

  create_table "tax_calculation_breakdowns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "explanation"
    t.json "inputs", default: {}
    t.decimal "result", precision: 12, scale: 2
    t.integer "sequence_order"
    t.string "step_key", null: false
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_return_id", "step_key"], name: "index_tax_calculation_breakdowns_on_tax_return_id_and_step_key"
    t.index ["tax_return_id"], name: "index_tax_calculation_breakdowns_on_tax_return_id"
  end

  create_table "tax_calculations", force: :cascade do |t|
    t.integer "box_definition_id"
    t.json "calculation_steps"
    t.string "calculation_type", null: false
    t.decimal "confidence_score", precision: 3, scale: 2, default: "1.0"
    t.datetime "created_at", null: false
    t.json "input_box_ids"
    t.json "input_values"
    t.decimal "result_value_gbp", precision: 15, scale: 2
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.index ["box_definition_id"], name: "index_tax_calculations_on_box_definition_id"
    t.index ["tax_return_id", "calculation_type"], name: "index_tax_calculations_on_tax_return_id_and_calculation_type"
    t.index ["tax_return_id"], name: "index_tax_calculations_on_tax_return_id"
  end

  create_table "tax_liabilities", force: :cascade do |t|
    t.decimal "additional_rate_tax", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "basic_rate_tax", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "calculated_at"
    t.string "calculated_by", default: "user_input"
    t.json "calculation_inputs", default: {}
    t.decimal "class_1_ni", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "class_2_ni", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "class_4_ni", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.decimal "higher_rate_tax", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "net_liability", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_paid_at_source", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "tax_return_id", null: false
    t.decimal "taxable_income", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_gross_income", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_income_tax", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_ni", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_tax_and_ni", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_return_id"], name: "index_tax_liabilities_on_tax_return_id", unique: true
  end

  create_table "tax_returns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "enabled_calculators", default: "gift_aid,hicbc"
    t.string "status", default: "draft", null: false
    t.integer "tax_year_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["enabled_calculators"], name: "index_tax_returns_on_enabled_calculators"
    t.index ["tax_year_id"], name: "index_tax_returns_on_tax_year_id"
    t.index ["user_id"], name: "index_tax_returns_on_user_id"
  end

  create_table "tax_years", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.string "label", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["label"], name: "index_tax_years_on_label", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "validation_rules", force: :cascade do |t|
    t.boolean "active", default: true
    t.json "condition"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "form_definition_id"
    t.json "required_field_box_ids"
    t.string "rule_code", null: false
    t.string "rule_type", null: false
    t.string "severity", default: "warning"
    t.datetime "updated_at", null: false
    t.index ["form_definition_id", "rule_type"], name: "index_validation_rules_on_form_definition_id_and_rule_type"
    t.index ["form_definition_id"], name: "index_validation_rules_on_form_definition_id"
    t.index ["rule_code"], name: "index_validation_rules_on_rule_code", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "box_definitions", "page_definitions"
  add_foreign_key "box_validations", "box_values"
  add_foreign_key "box_validations", "validation_rules"
  add_foreign_key "box_values", "box_definitions"
  add_foreign_key "box_values", "tax_returns"
  add_foreign_key "evidence_box_values", "box_values"
  add_foreign_key "evidence_box_values", "evidences"
  add_foreign_key "evidences", "tax_returns"
  add_foreign_key "export_evidences", "evidences"
  add_foreign_key "export_evidences", "exports"
  add_foreign_key "exports", "tax_returns"
  add_foreign_key "exports", "users"
  add_foreign_key "extraction_runs", "evidences"
  add_foreign_key "income_sources", "tax_returns"
  add_foreign_key "page_definitions", "form_definitions"
  add_foreign_key "tax_calculation_breakdowns", "tax_returns"
  add_foreign_key "tax_calculations", "box_definitions"
  add_foreign_key "tax_calculations", "tax_returns"
  add_foreign_key "tax_liabilities", "tax_returns"
  add_foreign_key "tax_returns", "tax_years"
  add_foreign_key "tax_returns", "users"
  add_foreign_key "validation_rules", "form_definitions"
end
