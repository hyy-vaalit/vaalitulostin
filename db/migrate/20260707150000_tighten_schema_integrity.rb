class TightenSchemaIntegrity < ActiveRecord::Migration[8.0]
  # The candidate import runs through psql \COPY (lib/support/psql.rb)
  # and bypasses ActiveRecord validations entirely, so the database is
  # the only enforcement layer. Duplicate candidate numbers would
  # silently corrupt results (P3.3).
  def change
    # No FK to faculties: existing candidate data carries faculty ids
    # without a matching faculties row (the faculty table is not part of
    # the candidate import), so an FK would reject legitimate data.
    add_index :candidates, :candidate_number, unique: true
    add_index :candidates, :electoral_alliance_id
    add_index :candidates, :faculty_id

    change_column_null :candidate_results, :result_id, false
    change_column_null :candidate_results, :candidate_id, false
    change_column_null :alliance_results, :result_id, false
    change_column_null :alliance_results, :electoral_alliance_id, false
    change_column_null :coalition_results, :result_id, false
    change_column_null :coalition_results, :electoral_coalition_id, false

    # ActiveAdmin was removed years ago; this table is an orphan.
    drop_table :active_admin_comments do |t|
      t.integer "resource_id", null: false
      t.string "resource_type", null: false
      t.integer "author_id"
      t.string "author_type"
      t.text "body"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.string "namespace"
      t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
      t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
      t.index ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id"
    end
  end
end
