class AdminController < ApplicationController

    # method for admin management
    def manage
        @foodie_database = User.where(account_type: "foodie").order("last_name")
        @chef_database = User.where(account_type: "chefhero").order("last_name")
        @dish_database = Dish.all.order("created_at DESC")
        @order_database = Order.all.order("created_at DESC")
        @review_database = Review.all.order("created_at DESC")

        @total_users = User.all.length
        
        @total_sales = 0
        @chef_database.each do |chef|
            @total_sales += chef.get_total_sales
        end

        @total_dishes = @dish_database.length
        @total_orders = @order_database.length
        @total_reviews = Review.all.length

        render layout: "admin"
    end

end
