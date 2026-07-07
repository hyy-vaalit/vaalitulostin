class AddSingleFrozenResultConstraints < ActiveRecord::Migration[8.0]
  # Belt and suspenders for the check-then-act guard in
  # Result.freeze_for_draws!: two workers or a double-click could
  # otherwise create two frozen results, and all draw code uses
  # Result.freezed.first.
  def change
    add_index :results, "(1)", unique: true, where: "freezed", name: "index_results_only_one_freezed"
    add_index :results, "(1)", unique: true, where: "final", name: "index_results_only_one_final"
  end
end
