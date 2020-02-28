class AddRevenueToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :revenue, :numeric
  end
end
