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

ActiveRecord::Schema[8.1].define(version: 2026_01_01_090800) do
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

  create_table "box_values", force: :cascade do |t|
    t.integer "box_definition_id", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "note"
    t.integer "scenario_id"
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.integer "value_gbp"
    t.string "value_raw"
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
    t.binary "encrypted_blob"
    t.string "filename", null: false
    t.string "mime"
    t.string "sha256"
    t.json "tags"
    t.integer "tax_return_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_return_id"], name: "index_evidences_on_tax_return_id"
  end

  create_table "form_definitions", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "version_meta"
    t.integer "year", null: false
    t.index ["code", "year"], name: "index_form_definitions_on_code_and_year", unique: true
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

  create_table "tax_returns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "draft", null: false
    t.integer "tax_year_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_year_id"], name: "index_tax_returns_on_tax_year_id"
  end

  create_table "tax_years", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.string "label", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["label"], name: "index_tax_years_on_label", unique: true
  end

  add_foreign_key "box_definitions", "page_definitions"
  add_foreign_key "box_values", "box_definitions"
  add_foreign_key "box_values", "tax_returns"
  add_foreign_key "evidence_box_values", "box_values"
  add_foreign_key "evidence_box_values", "evidences"
  add_foreign_key "evidences", "tax_returns"
  add_foreign_key "page_definitions", "form_definitions"
  add_foreign_key "tax_returns", "tax_years"
end
