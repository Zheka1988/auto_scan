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

ActiveRecord::Schema.define(version: 2021_11_19_055853) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.text "cidr"
    t.date "date_cidr"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date_last_nmap_scan"
    t.string "status_nmap_scan", default: "Not started"
    t.string "scan_ftp_status", default: "Not started"
  end

  create_table "ftp_results", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.bigint "ip_address_id", null: false
    t.text "results"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_ftp_results_on_country_id"
    t.index ["ip_address_id"], name: "index_ftp_results_on_ip_address_id"
  end

  create_table "ip_addresses", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "ip"
    t.boolean "port_21", default: false
    t.boolean "port_22", default: false
    t.boolean "port_443", default: false
    t.boolean "port_139", default: false
    t.boolean "port_445", default: false
    t.boolean "port_3389", default: false
    t.boolean "port_80", default: false
    t.boolean "port_8080", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date_last_scan"
    t.boolean "port_25", default: false
    t.index ["country_id"], name: "index_ip_addresses_on_country_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ftp_results", "countries"
  add_foreign_key "ftp_results", "ip_addresses"
  add_foreign_key "ip_addresses", "countries"
end
