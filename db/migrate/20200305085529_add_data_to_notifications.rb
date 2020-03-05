class AddDataToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :data, :numeric
  end
end
