class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable

    has_many :reviews
    has_many :dishes
    has_one_attached :avatar
    has_many :orders
    has_one :address
    has_one :availability
    has_many :withdrawals
    has_many :notifications

    # method for returning full name in string
    def name
        return "#{first_name} #{last_name}"
    end
    
	# search method to filter according to params parsed (fuzzy)
    def self.search(search)
		if search
			if search == "" || search == " "
				return User.where(account_type: "chefhero")
            end
            chefs = User.where(account_type: "chefhero")
			result = chefs.where("LOWER(first_name) LIKE ?", "%#{search.downcase}%")
			if result.length > 0
				return result
			else
				return self.where("LOWER(last_name) LIKE ?", "%#{search.downcase}%")
			end
		else
			User.where(account_type: "chefhero")
        end
        
	end

    # method for returning all dish ids associated with chef in array
    def get_dish_ids
        ids = []
        for dish in self.dishes
            ids.push(dish.id)
        end
        return ids
    end

    # method for getting user avatar- if not attached then default picture
    def get_display_picture
        return self.avatar.attached? ? self.avatar : "default-profile.png"
    end

    # method for returning withdrawn total of a user
    def get_withdrawn_total
        sum = 0
        records = self.withdrawals
        for record in records
            sum += record.amount
        end
        return sum
    end

    # method to calculate total sales of a chef/user
    def get_total_sales
        # sql query parsing dishes array to retrieve all associated orders
        orders = Order.where(dish_id: self.get_dish_ids)
        net = 0
        for order in orders
            net += order.get_total
        end
        return net
    end

    # method to return total orders for a user (integer)
    def get_total_orders
        orders = Order.where(dish_id: self.get_dish_ids)
        return orders.length
    end

    # method to return top 5 chefs ordered by total orders
    def self.top_five_chefs
        chefs = User.where(account_type: "chefhero")
        chef_to_orders = {}
        for chef in chefs
            chef_to_orders[chef.id] = chef.get_total_orders
        end
        sorted = chef_to_orders.sort_by(&:last).reverse[0..3]
        return sorted
    end

    # method return types of dishes to be displayed in chef bio on chef#index page
    def dish_types
        dishes = Dish.find(self.get_dish_ids)
        types = []
        dishes.each do |dish|
            types.push(dish.category) if types.include?(dish.category) == false
        end
        string = ""
        types.each_with_index do |type, index|
            if types.length == (index + 1)
                string += "#{type}"
            else
                string += "#{type}, "
            end
        end
        if string == ""
            string = "No dishes yet"
        end
        return string
    end

    # sort method to sort chefs by orders
    def self.sort_by_orders
		chef_to_orders = {}
		for chef in self.where(account_type: "chefhero")
            chef_to_orders[chef.id] = chef.get_total_orders
		end
		sorted = chef_to_orders.sort_by(&:last).reverse
		list = []
		for key,value in sorted
			list.push(User.find(key))
		end
		return list
    end
    
    # sort method to sort chefs by averating review rating
    def self.sort_by_rating
        chef_to_rating = {}
		for chef in self.where(account_type: "chefhero")
            chef_to_rating[chef.id] = chef.reviews.length > 0 ? chef.reviews.average(:rating) : 0
		end
		sorted = chef_to_rating.sort_by(&:last).reverse
		list = []
		for key,value in sorted
			list.push(User.find(key))
		end
		return list
    end

    # sort method by location
    def self.sort_by_location(search)
        return self.where("LOWER(location) LIKE ?", "%#{search.downcase}%" )
    end

    # method for returning last order
    def last_order
        return self.orders.order("created_at DESC").first
    end

end
