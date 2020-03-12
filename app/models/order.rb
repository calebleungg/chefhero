class Order < ApplicationRecord
	belongs_to :dish	

	# method for searching orders by name and id
	def self.search(search)
		if search
			# checking if search input is empty- if then return all
			if search == "" || search == " "
				return Order.all
			end
			
			# query returning single order (assuming user input searches by order id)
            if Order.where(id: search).length == 1
				return Order.where(id: search)
			# query returning all orders associated to parsed dish (assuming user input searches by dish)
			elsif Dish.search(search).first
				dish = Dish.search(search).first
				return Order.where(dish_id: dish.id)
			# query returning all orders associated to parsed user (assuming user input searches by user)
			else
                user = User.search(search, "all").first
                return Order.where(user_id: user.id)
			end
		end

		# returning all if search is nil
		return Order.all
        
	end

	# class method for filtering orders by dates- and dishes if parsed
	def self.filter_by_date(user, from_date, to_date, dishes)
		# instancing orders for parsed user
		orders = user.orders

		# filtering to orders of dishes if dish array is parsed (for chef order history filtering)
		if dishes
			orders = Order.where(dish_id: dishes, status: "collected")
		end
			
		# query to filter by parsed dates from-to 
		if from_date
			return orders.where(:created_at => from_date.to_date.beginning_of_day..to_date.to_date.end_of_day)
		else
			return orders
		end
	end

	# method for returning total orders for all dishes of one chef
	def self.total_for_chef(chef)
		total = 0
		dishes = Dish.where(user_id: chef.id)
		for dish in dishes
			total += Order.where(dish_id: dish.id).length
		end
		return total
	end

	# method for returning the user who placed the order
	def get_user
		return User.find(self.user_id)
	end

	# method for returning the chef of the order
	def get_chef
		return User.find(self.get_dish.get_chef.id)
	end

	# method for returning the dish of the order
	def get_dish
		return Dish.find(self.dish_id)
	end

	# method for returning an order total (price) 
	def get_total
		return self.revenue * self.quantity	 
	end

	# method for returning an array of all orders associated with parsed dish(id)
	def self.get_orders_of_dish(dish)
		orders = []
		Order.where(dish_id: dish).each do | order |
			orders.push(order.id)
		end
		return orders
	end

end
