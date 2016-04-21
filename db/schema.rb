# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150821102519) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_loggers", force: true do |t|
    t.string   "log_type"
    t.text     "input_val"
    t.text     "output_val"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "succeeded",    default: 0
    t.string   "app_version",  default: ""
    t.boolean  "cron_checked", default: false
    t.boolean  "web_checked",  default: false
  end

  create_table "api_tokens", force: true do |t|
    t.string   "access_token"
    t.string   "refresh_token"
    t.integer  "user_id",         null: false
    t.datetime "expiration_date"
    t.string   "ip_address"
  end

  create_table "companies", force: true do |t|
    t.text     "name",                   null: false
    t.text     "address",                null: false
    t.string   "phone",      limit: 25,  null: false
    t.string   "login",      limit: 55,  null: false
    t.string   "password",   limit: 128, null: false
    t.string   "salt",       limit: 50,  null: false
    t.datetime "last_login"
  end

  create_table "devices", force: true do |t|
    t.string  "platform",     limit: 20
    t.string  "os_version",   limit: 20
    t.string  "device_model", limit: 20
    t.integer "user_id",                 null: false
  end

  create_table "manager_drivers", force: true do |t|
    t.integer  "manager_id", null: false
    t.integer  "driver_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manufacturers", force: true do |t|
    t.string "description", null: false
  end

  create_table "mobile_logs", id: false, force: true do |t|
    t.integer  "user_id",                         null: false
    t.datetime "date",                            null: false
    t.text     "filename",                        null: false
    t.text     "reason",      default: "Unknown", null: false
    t.text     "description"
  end

  create_table "models", force: true do |t|
    t.string  "description",     null: false
    t.integer "manufacturer_id", null: false
  end

  create_table "periods", force: true do |t|
    t.integer  "user_id",                                  null: false
    t.datetime "start_date",                               null: false
    t.datetime "end_date"
    t.string   "status",           limit: 10,              null: false
    t.integer  "start_mileage",                            null: false
    t.integer  "end_mileage"
    t.string   "closed_by"
    t.boolean  "approved"
    t.string   "reminder_status"
    t.string   "agent_email"
    t.integer  "business_mileage",            default: 0
    t.integer  "private_mileage",             default: 0
    t.string   "approve_token",               default: ""
  end

  create_table "permissions", force: true do |t|
    t.string "description"
  end

  create_table "points", id: false, force: true do |t|
    t.datetime "timestamp",                    null: false
    t.float    "latitude",                     null: false
    t.float    "longitude",                    null: false
    t.boolean  "on_pause"
    t.integer  "trip_id"
    t.integer  "user_id",                      null: false
    t.float    "vehicle_speed", default: -1.0
  end

  add_index "points", ["trip_id"], name: "index_points_on_trip_id", using: :btree

  create_table "role_permissions", force: true do |t|
    t.integer "role_id"
    t.integer "permission_id"
  end

  create_table "roles", force: true do |t|
    t.string  "description"
    t.integer "access_level"
  end

  create_table "server_api_versions", id: false, force: true do |t|
    t.datetime "timestamp", default: "now()", null: false
    t.float    "version",                     null: false
  end

  create_table "settings", force: true do |t|
    t.integer  "red_line_value"
    t.integer  "orange_line_value"
    t.integer  "company_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_loggers", force: true do |t|
    t.integer  "connected_id"
    t.string   "event_type"
    t.string   "description"
    t.text     "old_value"
    t.text     "new_value"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tokens", force: true do |t|
    t.string   "access",    limit: 36,  null: false
    t.string   "refresh",   limit: 36,  null: false
    t.datetime "timestamp",             null: false
    t.string   "lifetime",  limit: nil, null: false
    t.integer  "user_id",               null: false
    t.integer  "device_id"
  end

  create_table "trips", force: true do |t|
    t.string   "estimated_time",     limit: nil,                 null: false
    t.datetime "start_date",                                     null: false
    t.datetime "end_date"
    t.float    "start_lat",                                      null: false
    t.float    "start_lon",                                      null: false
    t.float    "end_lat"
    t.float    "end_lon"
    t.integer  "start_mileage"
    t.integer  "end_mileage"
    t.text     "reason"
    t.string   "status",             limit: 10,                  null: false
    t.integer  "user_id",                                        null: false
    t.datetime "period_start_date"
    t.string   "vehicle_reg_number"
    t.string   "start_location"
    t.string   "end_location"
    t.integer  "mileage",                        default: 0
    t.integer  "period_id"
    t.boolean  "stats_gen",                      default: false
    t.integer  "private_mileage",                default: 0
  end

  create_table "user_permissions", force: true do |t|
    t.integer "user_id"
    t.integer "permission_id"
  end

  create_table "users", force: true do |t|
    t.integer  "user_type",                                       null: false
    t.text     "first_name",                                      null: false
    t.text     "last_name",                                       null: false
    t.string   "phone",               limit: 25
    t.string   "email",               limit: 50,                  null: false
    t.string   "password",            limit: 128,                 null: false
    t.string   "salt",                limit: 50,                  null: false
    t.datetime "last_login"
    t.boolean  "on_trip",                                         null: false
    t.integer  "company_id",                                      null: false
    t.string   "vehicle_reg_number"
    t.boolean  "is_line_manager",                 default: false
    t.boolean  "is_payroll_excluded",             default: false
    t.string   "api_version",                     default: ""
    t.string   "manager_type"
    t.string   "payroll_number",                  default: ""
    t.float    "lat",                             default: 0.0
    t.float    "lng",                             default: 0.0
    t.datetime "last_sync"
    t.string   "app_version"
    t.integer  "role_id"
  end

  create_table "vehicles", force: true do |t|
    t.integer "manufacturer_id", null: false
    t.integer "model_id",        null: false
    t.string  "registration",    null: false
    t.string  "color"
    t.float   "engine"
    t.integer "model_year"
    t.string  "transmission"
    t.string  "fuel_type"
  end

  add_foreign_key "devices", "users", name: "fk_devices_users"

  add_foreign_key "manager_drivers", "users", name: "manager_drivers_driver_id_fk", column: "driver_id"
  add_foreign_key "manager_drivers", "users", name: "manager_drivers_manager_id_fk", column: "manager_id"

  add_foreign_key "mobile_logs", "users", name: "fk_mobile_logs_users"

  add_foreign_key "periods", "users", name: "fk_periods_users"

  add_foreign_key "points", "trips", name: "fk_points_trips"
  add_foreign_key "points", "users", name: "fk_points_users"

  add_foreign_key "tokens", "devices", name: "fk_tokens_devices"
  add_foreign_key "tokens", "users", name: "fk_tokens_users"

  add_foreign_key "trips", "periods", name: "fk_trips_periods"
  add_foreign_key "trips", "users", name: "fk_trips_users"

  add_foreign_key "users", "companies", name: "fk_users_companies"

end
