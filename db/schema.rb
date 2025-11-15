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

ActiveRecord::Schema[7.2].define(version: 2025_11_15_165100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crop_groups", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "rotation_years", default: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_crop_groups_on_name", unique: true
  end

  create_table "cultivars", force: :cascade do |t|
    t.string "name", null: false
    t.string "marketing_name"
    t.text "description"
    t.integer "days_to_maturity_min"
    t.integer "days_to_maturity_max"
    t.integer "height_cm"
    t.integer "spread_cm"
    t.boolean "support_required"
    t.bigint "species_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cultivars_on_name"
    t.index ["species_id"], name: "index_cultivars_on_species_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.string "latin_name"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latin_name"], name: "index_families_on_latin_name", unique: true, where: "(latin_name IS NOT NULL)"
    t.index ["name"], name: "index_families_on_name"
  end

  create_table "genera", force: :cascade do |t|
    t.string "latin_name"
    t.bigint "family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id", "latin_name"], name: "index_genera_on_family_and_latin_name", unique: true, where: "((family_id IS NOT NULL) AND (latin_name IS NOT NULL))"
    t.index ["family_id"], name: "index_genera_on_family_id"
  end

  create_table "growing_profiles", force: :cascade do |t|
    t.bigint "cultivar_id", null: false
    t.string "region_code", null: false
    t.integer "sun_requirement", default: 0
    t.integer "spacing_in_row_cm"
    t.integer "spacing_between_rows_cm"
    t.integer "sow_indoors_from_month"
    t.integer "sow_indoors_to_month"
    t.integer "sow_outdoors_from_month"
    t.integer "sow_outdoors_to_month"
    t.integer "harvest_from_month"
    t.integer "harvest_to_month"
    t.boolean "frost_hardy"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cultivar_id"], name: "index_growing_profiles_on_cultivar_id"
    t.index ["region_code", "cultivar_id"], name: "index_growing_profiles_on_region_and_cultivar", unique: true
  end

  create_table "species", force: :cascade do |t|
    t.string "latin_name"
    t.string "common_name"
    t.integer "plant_type", default: 0, null: false
    t.integer "life_cycle", default: 0, null: false
    t.text "description"
    t.bigint "genus_id"
    t.bigint "crop_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["common_name"], name: "index_species_on_common_name"
    t.index ["crop_group_id"], name: "index_species_on_crop_group_id"
    t.index ["genus_id"], name: "index_species_on_genus_id"
    t.index ["latin_name"], name: "index_species_on_latin_name", unique: true, where: "(latin_name IS NOT NULL)"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cultivars", "species"
  add_foreign_key "genera", "families"
  add_foreign_key "growing_profiles", "cultivars"
  add_foreign_key "species", "crop_groups"
  add_foreign_key "species", "genera", column: "genus_id"
end
