class Dish < ApplicationRecord
	belongs_to :user
	has_one_attached :image
	has_many :order

	# search method to filter according to params parsed (fuzzy)
	def self.search(search)
		if search
			if search == "" || search == " "
				return Dish.all
			end
			result = self.where("LOWER(name) LIKE ?", "%#{search.downcase}%")
			if result.length > 0
				return result
			else
				return self.where("LOWER(category) LIKE ?", "%#{search.downcase}%")
			end
		else
			Dish.all
		end
	end

	# method to return attached image- or default if nil
	def get_image
        return self.image.attached? ? self.image : "default-dish.png"
	end

	# method to return the chef of a dish
	def get_chef
		return User.find(self.user_id)
	end
	
	# method to return total quantity ordered for a dish (unique)
	def total_quantity
		orders = Order.where(dish_id: self.id)
		total_quantity = 0
		for order in orders
			total_quantity += order.quantity
		end
		return total_quantity
	end

	# method to return total orders made for dish (order level)
	def total_orders
		return Order.where(dish_id: self.id).order("created_at DESC") 
	end

	# method to return top 5 dishes sorted by total quantity
	def self.top_five_dishes
		dishes = Dish.where(available: true)
		dish_to_orders = {}
		for dish in dishes
            dish_to_orders[dish.id] = dish.total_quantity
		end
		sorted = dish_to_orders.sort_by(&:last).reverse[0..3]
		return sorted
	end

	# method to sort search filter by orders desc
	def self.sort_by_orders
		dish_to_orders = {}
		for dish in self.all
            dish_to_orders[dish.id] = dish.total_quantity
		end
		sorted = dish_to_orders.sort_by(&:last).reverse
		list = []
		for key,value in sorted
			list.push(Dish.find(key))
		end
		return list
	end

	# method to sort search filter by created_at desc
	def self.sort_by_newest
		dish_to_created = {}
		for dish in self.all
			dish_to_created[dish.id] = dish.created_at
		end
		sorted = dish_to_created.sort_by(&:last).reverse
		list = []
		for key,value in sorted
			list.push(Dish.find(key))
		end
		return list
	end
	
end
