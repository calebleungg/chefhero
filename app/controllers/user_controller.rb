require "date_format"

class UserController < ApplicationController

    # splash page instance method
    def index
        @top_chefs = User.top_five_chefs
        @top_dishes = Dish.top_five_dishes
        if user_signed_in? && current_user.account_type == "admin"
            render layout: "admin"
        end
    end

    # method for chef index page with sort options
    def chefs
        @chefs = User.search(params[:search], "chefhero")
        if params[:location]
            @chefs = @chefs.sort_by_location(params[:location])
        end
        if params[:sort] == "ordered"
            @chefs = @chefs.sort_by_orders
        end
        if params[:sort] == "top"
            @chefs = @chefs.sort_by_rating
        end
        if user_signed_in? && current_user.account_type == "admin"
            render layout: "admin"
        end
    end

    # method for displaying user profile
    def show
        if params[:notification_id]
            Notification.find(params[:notification_id]).destroy
            redirect_to user_path(params[:id])
        else

            @user = User.find(params[:id])

            # instancing user revies if chef
            @reviews = @user.reviews.order("created_at DESC")

            # instancing user about with error handling when editing with Tiny  MCE
            if @user.about == nil
                @about = ""
            else
                @about = @user.about
            end
            
            # instancing info in user profile is a chef
            if @user.account_type == "chefhero"
                @dishes = @user.dishes.where(available: true).order("created_at DESC").limit(5)
                @total_orders = Order.total_for_chef(@user)
                @days_open = @user.availability.days_open if @user.availability
                begin
                    @address_coordinates = Geocoder.search(@user.address.display_full).first.coordinates.reverse if @user.address
                rescue
                    # rescue method for catching error thrown by incorrect coordinates by user inputted address
                    @address_coordinates = nil
                end
                @average_rating = @user.reviews.average(:rating)
            end
        end
        if user_signed_in? && current_user.account_type == "admin"
            render layout: "admin"
        end

    end
    
    # method for attaching a profile photo 
    def upload_photo
        @user = current_user
        @user.avatar.attach(params[:user][:avatar])
        if @user.save
            redirect_to user_path(@user)
        end
    end

    # method for saving about edit
    def update_about
        @user = current_user
        @user.update(user_params)
        if @user.valid? && @user.save
            redirect_to user_path(@user)
        end
    end

    # method for account details display (empty as used current_user for most instance calls in view)
    def details
        if current_user.favourites_list
            @list = current_user.favourites_list_items
        end
    end

    # view method for edit 
    def edit
        @user = current_user
    end

    # method for saving edits as above
    def update
        @user = current_user
        @user.update!(user_params)

        if @user.valid? && @user.save
            flash[:notice] = "Saved successfully."
            redirect_to details_path
        else
            flash[:alert] = "Something went wrong when trying to save. Try again."
            render "edit"
        end
    end

    # empty dashboard method to link dashboard direction view
    def dashboard
    end

    # method for chef dish/availability/location manager
    def manager
        @user = current_user
        @dishes = @user.dishes.order("created_at DESC")
        @availability = @user.availability
        @address = @user.address
        
        render layout: "dashboard"
    end

    # view method for new chef registration
    def new_chef
        @user = current_user
    end

    # create method for new chef as about (updating default user type to "chefhero")
    def create_chef
        user = current_user
        # saving new created address
        user.create_address(
            street: params[:user][:street],
            suburb: params[:user][:suburb],
            city: params[:user][:city],
            state: params[:user][:state],
            postcode: params[:user][:postcode],
            country: params[:user][:country]
        )
        # saving new created availability
        user.create_availability(
            monday: params[:user][:monday],
            tuesday: params[:user][:tuesday],
            wednesday: params[:user][:wednesday],
            thursday: params[:user][:thursday],
            friday: params[:user][:friday],
            saturday: params[:user][:saturday],
            sunday: params[:user][:sunday],
        )
        user.account_type = "chefhero"
        if user.valid? && user.save
            redirect_to manager_path(:option => "Manager")
        else 
            render "new_chef"
        end
    end

    # method for deleting a user and all relevant info
    def delete
        user = User.find(params[:id])
        dishes = user.get_dish_ids
        Notification.where(data: Order.get_orders_of_dish(dishes)).destroy_all
        Order.where(dish_id: dishes).destroy_all
        Notification.where(data: user.id).destroy_all
        FavouritesListItem.where(user_id: user.id).destroy_all
        user.dishes.destroy_all
        user.destroy
        Review.where(left_by: params[:id]).destroy_all
        redirect_back(fallback_location: root_path)
    end

    # method for displaying analytics 
    def analytics
        user = current_user
        dish_ids = user.get_dish_ids

        # instancing dishes for the past month
        @orders = Order.where(dish_id: dish_ids, :created_at => Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)

        # hash variables for sorting 
        @total_sales = 0
        @sales_by_dish = Hash.new{0}
        @sales_by_day = Hash.new{0}
        @orders_by_dish = Hash.new{0}
        @customers = Hash.new{0}
        @sales_by_suburb = Hash.new{0}

        # instancing information of orders for the past week
        @week = @orders.where("created_at >= ?", 1.week.ago.utc)
        @weekly_sales = Hash.new{0} 
        @week.each do |order|
            @weekly_sales[DateFormat.change_to(order.created_at, "ONLY_CURRENT_DATE_ALPHABET")] += order.get_total
        end
        
        # interating through monthly orders and appending key value pairs for info sorting
        @orders.each do |order|
            @sales_by_dish[order.get_dish.name] += order.get_total
            @orders_by_dish[order.get_dish.name] += 1
            @sales_by_day[DateFormat.change_to(order.created_at, "SHORT_DATE")] += order.get_total
            @total_sales += order.get_total
            @customers[order.get_user.name] += 1
            @sales_by_suburb[order.get_user.location] += order.get_total
        end 

        @sales_by_dish = @sales_by_dish.sort_by(&:last).reverse
        # average order value
        @aov = @orders.length > 0 ? @total_sales / @orders.length : 0

        render layout: "dashboard"
    end

    private
    def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :phone, :location, :about, :avatar)
    end
end
