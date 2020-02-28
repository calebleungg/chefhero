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
	
	def total_quantity
		orders = Order.where(dish_id: self.id)
		total_quantity = 0
		for order in orders
			total_quantity += order.quantity
		end
		return total_quantity
	end

	def total_orders
		return Order.where(dish_id: self.id).order("created_at DESC") 
	end

	def self.top_five_dishes
		dishes = Dish.where(available: true)
		dish_to_orders = {}
		for dish in dishes
            dish_to_orders[dish.id] = dish.total_quantity
		end
		sorted = dish_to_orders.sort_by(&:last).reverse[0..3]
		return sorted
	end
	
end
