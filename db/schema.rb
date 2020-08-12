# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_12_041750) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "carings", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.bigint "doctor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["doctor_id"], name: "index_carings_on_doctor_id"
    t.index ["patient_id"], name: "index_carings_on_patient_id"
  end

  create_table "diseases", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "diseasings", force: :cascade do |t|
    t.bigint "disease_id", null: false
    t.bigint "patient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disease_id"], name: "index_diseasings_on_disease_id"
    t.index ["patient_id"], name: "index_diseasings_on_patient_id"
  end

  create_table "doctors", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "avatar"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "name"
    t.integer "age"
    t.string "email"
    t.string "gender"
    t.string "phone"
    t.float "height"
    t.string "diagnosis"
    t.string "avatar"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.float "weight"
  end

  create_table "vital_signals", force: :cascade do |t|
    t.float "respiratory_rate"
    t.float "heart_rate"
    t.float "temperature"
    t.float "diastolic_pressure"
    t.float "systolic_pressure"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "patient_id", null: false
    t.index ["patient_id"], name: "index_vital_signals_on_patient_id"
  end

  add_foreign_key "carings", "doctors"
  add_foreign_key "carings", "patients"
  add_foreign_key "diseasings", "diseases"
  add_foreign_key "diseasings", "patients"
  add_foreign_key "vital_signals", "patients"
end
