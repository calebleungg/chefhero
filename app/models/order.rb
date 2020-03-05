class Order < ApplicationRecord
	belongs_to :dish

	def self.filter_by_date(user, from_date, to_date, dishes)
		orders = user.orders
		if dishes
			orders = Order.where(dish_id: dishes, status: "collected")
		end
			
		if from_date
			return orders.where(:created_at => from_date.to_date.beginning_of_day..to_date.to_date.end_of_day)
		else
			return orders
		end
	end

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
