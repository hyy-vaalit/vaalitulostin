class DropCandidateAttributeChanges < ActiveRecord::Migration[5.0]
  def change
    drop_table :candidate_attribute_changes
  end
end
