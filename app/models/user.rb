class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable

    has_many :reviews, dependent: :destroy
    has_many :dishes, dependent: :destroy
    has_one_attached :avatar
    has_many :orders, dependent: :destroy
    has_one :address, dependent: :destroy
    has_one :availability, dependent: :destroy
    has_many :withdrawals, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_one :favourites_list, dependent: :destroy
    has_many :favourites_list_items, through: :favourites_list


    # method for returning full name in string
    def name
        return "#{first_name} #{last_name}"
    end
    
	# search method to filter according to params parsed (fuzzy)
    def self.search(search, type)
		if search
            if search == "" || search == " "
                # returning all if parsed type variable is "all"
                if type == "all"
                    return User.all
                end
                # returning all users of account_type of parsed type variable
				return User.where(account_type: type)
            end
            if type == "all"
                users = User.all
                # query returning all users with fuzzy similarity to multiple columns first_name, last_name, or email
                return users.where("LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search", search: "%#{search.downcase}%")
            else
                chefs = User.where(account_type: type)
                return chefs.where("LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search", search: "%#{search.downcase}%")
            end
        else
            if type == "all"
                return User.all
            end
			return User.where(account_type: type)
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
        # instancing all chefs
        chefs = User.where(account_type: "chefhero")

        # interating through chefs and appending to new hash a key, pair value of chef_id => total orders
        chef_to_orders = {}
        for chef in chefs
            chef_to_orders[chef.id] = chef.get_total_orders
        end

        # sorting by total orders
        sorted = chef_to_orders.sort_by(&:last).reverse[0..3]
        return sorted
    end

    # method return types of dishes to be displayed in chef bio on chef#index page
    def dish_types

        # instancing all dishes by parsed dish ids (of current user)
        dishes = Dish.find(self.get_dish_ids)

        # appending the categories of dish to types array without repeats
        types = []
        dishes.each do |dish|
            types.push(dish.category) if types.include?(dish.category) == false
        end

        # adding each category to a string to be returned in display
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

        # similar sort method as seen in Order, Dish models (see there for explanation)
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

        # similar sort method as seen in Order, Dish models (see there for explanation)
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
        # query return for fuzzy input in location search
        return self.where("LOWER(location) LIKE ?", "%#{search.downcase}%" )
    end

    # method for returning last order
    def last_order
        return self.orders.order("created_at DESC").first
    end

    # method for checking favourites
    def check_if_faved(chef)
		if self.favourites_list
			return self.favourites_list.favourites_list_items.exists?(user_id: chef)
		end
		return false
    end
    
    # method for checking total favourites
    def total_favourites
        return FavouritesListItem.where(user_id: self.id).length
    end

    # method for returning a general user total spent
    def total_spent
        orders = self.orders
        total = 0
        orders.each do |order|
            total += order.get_total
        end
        return total
    end

end
