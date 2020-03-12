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

end
