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

ActiveRecord::Schema[8.0].define(version: 2026_07_07_160000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "alliance_draws", force: :cascade do |t|
    t.integer "result_id"
    t.string "identifier"
    t.boolean "affects_elected_candidates", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "alliance_proportionals", force: :cascade do |t|
    t.integer "candidate_id", null: false
    t.integer "result_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.float "number", null: false
    t.integer "numerator"
    t.integer "denominator"
    t.index ["candidate_id", "result_id"], name: "index_unique_alliance_prop_per_candidate_and_result", unique: true
  end

  create_table "alliance_results", force: :cascade do |t|
    t.integer "result_id", null: false
    t.integer "electoral_alliance_id", null: false
    t.integer "vote_sum_cache"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["electoral_alliance_id", "result_id"], name: "index_unique_alliance_result", unique: true
  end

  create_table "candidate_draws", force: :cascade do |t|
    t.integer "result_id"
    t.string "identifier"
    t.boolean "affects_elected_candidates"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "candidate_results", force: :cascade do |t|
    t.integer "result_id", null: false
    t.integer "candidate_id", null: false
    t.integer "vote_sum_cache"
    t.boolean "elected", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "alliance_draw_id"
    t.integer "coalition_draw_id"
    t.integer "alliance_draw_order"
    t.integer "coalition_draw_order"
    t.integer "candidate_draw_id"
    t.integer "candidate_draw_order"
    t.index ["candidate_id", "result_id"], name: "index_unique_candidate_result", unique: true
  end

  create_table "candidates", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "candidate_name"
    t.string "social_security_number"
    t.integer "faculty_id"
    t.string "address"
    t.string "postal_information"
    t.string "email"
    t.integer "electoral_alliance_id"
    t.integer "candidate_number"
    t.text "notes"
    t.integer "numbering_order"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "phone_number"
    t.index ["candidate_number"], name: "index_candidates_on_candidate_number", unique: true
    t.index ["electoral_alliance_id"], name: "index_candidates_on_electoral_alliance_id"
    t.index ["faculty_id"], name: "index_candidates_on_faculty_id"
  end

  create_table "coalition_draws", force: :cascade do |t|
    t.integer "result_id"
    t.string "identifier"
    t.boolean "affects_elected_candidates", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "coalition_proportionals", force: :cascade do |t|
    t.integer "candidate_id", null: false
    t.integer "result_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.float "number", null: false
    t.integer "numerator"
    t.integer "denominator"
    t.index ["candidate_id", "result_id"], name: "index_unique_coalition_prop_per_candidate_and_result", unique: true
  end

  create_table "coalition_results", force: :cascade do |t|
    t.integer "result_id", null: false
    t.integer "electoral_coalition_id", null: false
    t.integer "vote_sum_cache"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["electoral_coalition_id", "result_id"], name: "index_unique_coalition_result", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "queue"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "electoral_alliances", force: :cascade do |t|
    t.string "name"
    t.integer "expected_candidate_count"
    t.boolean "secretarial_freeze", default: false
    t.integer "electoral_coalition_id"
    t.integer "numbering_order"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "shorten"
  end

  create_table "electoral_coalitions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "numbering_order"
    t.string "shorten"
  end

  create_table "emails", force: :cascade do |t|
    t.string "subject"
    t.text "content"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "enqueued_at", precision: nil
  end

  create_table "faculties", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "global_configurations", force: :cascade do |t|
    t.integer "votes_given", default: 0
    t.integer "votes_accepted", default: 0
    t.integer "potential_voters_count", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.float "voting_percentage"
  end

  create_table "results", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "final", default: false, null: false
    t.boolean "freezed", default: false, null: false
    t.boolean "candidate_draws_ready", default: false, null: false
    t.boolean "alliance_draws_ready", default: false, null: false
    t.boolean "coalition_draws_ready", default: false, null: false
    t.boolean "in_process", default: false, null: false
    t.integer "vote_sum_cache", default: 0, null: false
    t.boolean "published", default: false, null: false
    t.boolean "published_pending", default: false, null: false
    t.index "(1)", name: "index_results_only_one_final", unique: true, where: "final"
    t.index "(1)", name: "index_results_only_one_freezed", unique: true, where: "freezed"
  end

  create_table "voters", force: :cascade do |t|
    t.string "name", null: false
    t.string "student_number", null: false
    t.string "ssn", null: false
    t.integer "start_year"
    t.datetime "voted_at", precision: nil
    t.integer "voting_area_id"
    t.integer "faculty_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "extent_of_studies"
    t.index ["name"], name: "index_voters_on_name"
    t.index ["ssn"], name: "index_voters_on_ssn", unique: true
    t.index ["student_number"], name: "index_voters_on_student_number", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "voting_area_id", null: false
    t.integer "candidate_id", null: false
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "fixed_amount"
    t.index ["candidate_id", "voting_area_id"], name: "index_unique_votes_per_candidate_in_voting_area", unique: true
  end

  create_table "voting_areas", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "ready", default: false, null: false
    t.boolean "submitted", default: false, null: false
    t.index ["code"], name: "index_unique_voting_area_code", unique: true
  end

  add_foreign_key "alliance_draws", "results", name: "alliance_draws_result_id_fk"
  add_foreign_key "alliance_proportionals", "candidates", name: "alliance_proportionals_candidate_id_fk"
  add_foreign_key "alliance_proportionals", "results", name: "alliance_proportionals_result_id_fk"
  add_foreign_key "alliance_results", "electoral_alliances", name: "alliance_results_electoral_alliance_id_fk"
  add_foreign_key "alliance_results", "results", name: "alliance_results_result_id_fk"
  add_foreign_key "candidate_draws", "results", name: "candidate_draws_result_id_fk"
  add_foreign_key "candidate_results", "alliance_draws", name: "candidate_results_alliance_draw_id_fk"
  add_foreign_key "candidate_results", "candidate_draws", name: "candidate_results_candidate_draw_id_fk"
  add_foreign_key "candidate_results", "candidates", name: "candidate_results_candidate_id_fk"
  add_foreign_key "candidate_results", "coalition_draws", name: "candidate_results_coalition_draw_id_fk"
  add_foreign_key "candidate_results", "results", name: "candidate_results_result_id_fk"
  add_foreign_key "candidates", "electoral_alliances", name: "candidates_electoral_alliance_id_fk"
  add_foreign_key "coalition_draws", "results", name: "coalition_draws_result_id_fk"
  add_foreign_key "coalition_proportionals", "candidates", name: "coalition_proportionals_candidate_id_fk"
  add_foreign_key "coalition_proportionals", "results", name: "coalition_proportionals_result_id_fk"
  add_foreign_key "coalition_results", "electoral_coalitions", name: "coalition_results_electoral_coalition_id_fk"
  add_foreign_key "coalition_results", "results", name: "coalition_results_result_id_fk"
  add_foreign_key "electoral_alliances", "electoral_coalitions", name: "electoral_alliances_electoral_coalition_id_fk"
  add_foreign_key "voters", "faculties", name: "voters_faculty_id_fk"
  add_foreign_key "voters", "voting_areas", name: "voters_voting_area_id_fk"
  add_foreign_key "votes", "candidates", name: "votes_candidate_id_fk"
  add_foreign_key "votes", "voting_areas", name: "votes_voting_area_id_fk"
end
