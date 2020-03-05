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

    def name
        return "#{first_name} #{last_name}"
    end
    
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

    def get_dish_ids
        ids = []
        for dish in self.dishes
            ids.push(dish.id)
        end
        return ids
    end

    def get_display_picture
        return self.avatar.attached? ? self.avatar : "default-profile.png"
    end

    def get_withdrawn_total
        sum = 0
        records = self.withdrawals
        for record in records
            sum += record.amount
        end
        return sum
    end

    def get_total_sales
        orders = Order.where(dish_id: self.get_dish_ids)
        net = 0
        for order in orders
            net += order.get_total
        end
        return net
    end

    def get_total_orders
        orders = Order.where(dish_id: self.get_dish_ids)
        return orders.length
    end

    def self.top_five_chefs
        chefs = User.where(account_type: "chefhero")
        chef_to_orders = {}
        for chef in chefs
            chef_to_orders[chef.id] = chef.get_total_orders
        end
        sorted = chef_to_orders.sort_by(&:last).reverse[0..3]
        return sorted
    end

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

    def self.sort_by_location(search)
        return self.where("LOWER(location) LIKE ?", "%#{search.downcase}%" )
    end

end
