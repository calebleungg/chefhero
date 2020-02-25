class ChangeAboutToBeTextInUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :about, :text
  end
end
