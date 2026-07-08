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

ActiveRecord::Schema[7.2].define(version: 2026_07_08_130532) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_employees_on_name", unique: true
  end

  create_table "meeting_participants", force: :cascade do |t|
    t.bigint "meeting_id", null: false
    t.bigint "employee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.index ["employee_id"], name: "index_meeting_participants_on_employee_id"
    t.index ["meeting_id", "employee_id"], name: "index_meeting_participants_on_meeting_id_and_employee_id", unique: true
    t.index ["meeting_id"], name: "index_meeting_participants_on_meeting_id"
    t.exclusion_constraint "employee_id WITH =, tsrange(starts_at, ends_at) WITH &&", using: :gist, name: "no_overlapping_meetings"
  end

  create_table "meetings", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_meetings_on_starts_at"
  end

  add_foreign_key "meeting_participants", "employees"
  add_foreign_key "meeting_participants", "meetings"
end
