class Order < ApplicationRecord
	belongs_to :dish

	def self.total_for_chef(chef)
		total = 0
		dishes = Dish.where(user_id: chef.id)
		for dish in dishes
			total += Order.where(dish_id: dish.id).length
		end
		return total
	end

	def get_user
		return User.find(self.user_id)
	end

	def get_dish
		return Dish.find(self.dish_id)
	end

	def get_total
		return self.revenue * self.quantity	 
	end

	def self.last_order
		return Order.all.order("created_at DESC").first 
	end

end
