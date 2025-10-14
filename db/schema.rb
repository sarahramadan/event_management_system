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

ActiveRecord::Schema[7.1].define(version: 2025_10_13_185647) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ticket_statuses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ticket_statuses_on_name", unique: true
  end

  create_table "tickets", force: :cascade do |t|
    t.string "reference_id", null: false
    t.bigint "user_id"
    t.bigint "ticket_status_id"
    t.datetime "purchase_date"
    t.string "release_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference_code"
    t.integer "quantity"
    t.decimal "price"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_tickets_on_deleted_at"
    t.index ["purchase_date"], name: "index_tickets_on_purchase_date"
    t.index ["reference_code"], name: "index_tickets_on_reference_code"
    t.index ["reference_id"], name: "index_tickets_on_reference_id", unique: true
    t.index ["ticket_status_id"], name: "index_tickets_on_ticket_status_id"
    t.index ["user_id", "ticket_status_id"], name: "index_tickets_on_user_id_and_ticket_status_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "phone_number"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "tickets", "ticket_statuses", on_delete: :nullify
  add_foreign_key "tickets", "users", on_delete: :restrict
end
