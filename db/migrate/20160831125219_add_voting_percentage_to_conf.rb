class AddVotingPercentageToConf < ActiveRecord::Migration[5.0]
  def change
    add_column :global_configurations, :voting_percentage, :float
  end
end
