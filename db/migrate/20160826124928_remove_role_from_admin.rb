class RemoveRoleFromAdmin < ActiveRecord::Migration[5.0]
  def change
    remove_column :admin_users, :role
  end
end
