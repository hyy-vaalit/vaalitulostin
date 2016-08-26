class RemoveAdvocates < ActiveRecord::Migration[5.0]
  def change
    remove_column :electoral_alliances, :primary_advocate_id
    remove_column :electoral_alliances, :secondary_advocate_id
    remove_column :global_configurations, :advocate_login_enabled

    drop_table :advocate_users

  end
end
