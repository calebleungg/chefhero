class AddDetailsToUser < ActiveRecord::Migration[5.2]
	def change
		add_column :users, :first_name, :string
		add_column :users, :last_name, :string
		add_column :users, :phone, :numeric
		add_column :users, :location, :string
		add_column :users, :account_type, :string
	end
end
