class AddExactFractionsToProportionals < ActiveRecord::Migration[8.0]
  # The float `number` (rounded to 5 decimals) stays for display and
  # rendering compatibility; ties are detected from the exact reduced
  # fraction so two distinct proportionals rounding to the same 5
  # decimals can no longer create a false draw (P0.7).
  def change
    add_column :alliance_proportionals, :numerator, :integer
    add_column :alliance_proportionals, :denominator, :integer
    add_column :coalition_proportionals, :numerator, :integer
    add_column :coalition_proportionals, :denominator, :integer
  end
end
