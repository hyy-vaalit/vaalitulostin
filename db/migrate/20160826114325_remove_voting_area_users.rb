class RemoveVotingAreaUsers < ActiveRecord::Migration[5.0]
  def change
    drop_table :voting_area_users
  end
end
