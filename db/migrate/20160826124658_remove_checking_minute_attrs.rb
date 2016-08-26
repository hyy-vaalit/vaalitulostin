class RemoveCheckingMinuteAttrs < ActiveRecord::Migration[5.0]
  def change
    remove_column :global_configurations, :checking_minutes_username
    remove_column :global_configurations, :checking_minutes_password
  end
end
