class Dish < ApplicationRecord
	belongs_to :user
	has_one_attached :image
	has_many :order

	def get_image
        return self.image.attached? ? self.image : "default-dish.png"
	end

	def get_chef
		return User.find(self.user_id)
	end
	
	def total_orders
		orders = Order.where(dish_id: self.id)
		total_quantity = 0
		for order in orders
			total_quantity += order.quantity
		end
		return total_quantity
	end
	
end
