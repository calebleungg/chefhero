class Review < ApplicationRecord
    belongs_to :user

    # search method similar to Dish, Order, and User models
    def self.search(search)
        if search
            if search == "" || search == " "
                return Review.all
            end

            users = User.search(search, "all")

            ids = []
            users.each do |user|
                ids.push(user.id)
            end
            return Review.where(left_by: ids)
        end
        return Review.all
    end

    # method for returning user leaving review
    def get_left_by_user
        return User.find(self.left_by)
    end

    # method for returning user review for
    def get_user
        return User.find(self.user_id)
    end

end
