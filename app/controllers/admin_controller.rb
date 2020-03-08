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

        if params[:foodie_search] && params[:foodie_search] != "" && params[:foodie_search] != " "        
            if User.where(id: params[:foodie_search]).length > 0
                @foodie_database = User.where(id: params[:foodie_search])
            else
                @foodie_database = @foodie_database.where("LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search",  search: "%#{params[:foodie_search].downcase}%")
            end
        end

        if params[:chef_search] && params[:chef_search] != "" && params[:chef_search] != " "
            if User.where(id: params[:chef_search]).length > 0
                @chef_database = User.where(id: params[:chef_search])
            else
                @chef_database = @chef_database.where("LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search",  search: "%#{params[:chef_search].downcase}%")
            end
        end
        
        if params[:dish_search] && params[:dish_search] != "" && params[:dish_search] != " "
            if Dish.where(id: params[:dish_search]).length > 0
                @dish_database = Dish.where(id: params[:dish_search])
            else
                @dish_database = @dish_database.where("LOWER(name) LIKE :search OR LOWER(category) LIKE :search",  search: "%#{params[:dish_search].downcase}%")
            end
        end

        if params[:order_search] && params[:order_search] != "" && params[:order_search] != " "
            if Order.where(id: params[:order_search]).length == 1
                @order_database = Order.where(id: params[:order_search])
            else
                tmp = User.where("LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search",  search: "%#{params[:order_search].downcase}%")
                ids = []
                tmp.each do |user|
                    ids.push(user.id)
                end
                @order_database = @order_database.where(user_id: ids)
            end
        end

        if params[:review_search] && params[:review_search] != "" && params[:review_search] != " "
            tmp = User.where("LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search OR LOWER(email) LIKE :search",  search: "%#{params[:review_search].downcase}%")
            ids = []
            tmp.each do |user|
                ids.push(user.id)
            end
            @review_database = @review_database.where(left_by: ids)
        end

        render layout: "admin"
    end

end
