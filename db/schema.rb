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

ActiveRecord::Schema[8.0].define(version: 2025_10_21_032438) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "full_name"
    t.string "uid"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "member"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["role"], name: "index_admins_on_role"
    t.index ["uid"], name: "index_admins_on_uid", unique: true
  end

  create_table "calendars", force: :cascade do |t|
    t.string "title"
    t.datetime "event_date"
    t.text "description"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "event_signups", force: :cascade do |t|
    t.string "user_email"
    t.string "user_name"
    t.bigint "calendar_id", null: false
    t.datetime "signed_up_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_event_signups_on_calendar_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "calendar_id", null: false
    t.string "status", default: "registered", null: false
    t.text "notes"
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_registrations_on_calendar_id"
    t.index ["status"], name: "index_registrations_on_status"
    t.index ["user_id", "calendar_id"], name: "index_registrations_on_user_id_and_calendar_id", unique: true
    t.index ["user_id"], name: "index_registrations_on_user_id"
  end

  create_table "signups", force: :cascade do |t|
    t.bigint "calendar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "admin_id", null: false
    t.index ["admin_id", "calendar_id"], name: "index_signups_on_admin_id_and_calendar_id", unique: true
    t.index ["admin_id"], name: "index_signups_on_admin_id"
    t.index ["calendar_id"], name: "index_signups_on_calendar_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "full_name"
    t.string "uid"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "member"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "calendars", "users"
  add_foreign_key "event_signups", "calendars"
  add_foreign_key "registrations", "calendars"
  add_foreign_key "registrations", "users"
  add_foreign_key "signups", "admins"
  add_foreign_key "signups", "calendars"
end
