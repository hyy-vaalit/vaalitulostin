class RemoveNumericCodeFromFaculty < ActiveRecord::Migration[5.0]
  def change
    remove_column :faculties, :numeric_code
  end
end
