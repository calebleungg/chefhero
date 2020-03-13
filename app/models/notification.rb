class Notification < ApplicationRecord
  belongs_to :user

	# method to return order through notif metadata
	def get_order
		return Order.find(self.data)
	end

	# method to return user through notif metadata
	def get_user
		return User.find(self.data)
	end

end
