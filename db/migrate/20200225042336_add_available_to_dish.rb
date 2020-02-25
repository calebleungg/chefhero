class AddAvailableToDish < ActiveRecord::Migration[5.2]
  def change
    add_column :dishes, :available, :boolean
  end
end
