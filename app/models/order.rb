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
		return self.get_dish.price * self.quantity	 
	end

end
