class DishController < ApplicationController

    # simple instance of dish model for use in create method
    def new
        @dish = Dish.new
    end

    # index method for dishes
    def index
        # filter/sort depending on search paramaters passed (or not)
        filter = Dish.search(params[:search])
        @dishes = filter.where(available: true)

        # layered filtering check to call class sort method if parsed 
        if params[:sort] == "ordered"
            @dishes = @dishes.sort_by_orders
        end
        if params[:sort] == "newest"
            @dishes = @dishes.sort_by_newest
        end

        # rendering admin theme if admin
        if user_signed_in? && current_user.account_type == "admin"
            render layout: "admin"
        end

    end

    # post method for creating a dish
    def create
        @dish = current_user.dishes.create(dish_params)
        @dish.image.attach(params[:dish][:image])
        @dish.available = true
        # validation check
        if @dish.valid? && @dish.save
            # creating notifications for all users who have favourited this chef
            to_notify = FavouritesList.return_notif_list(current_user.id)
            to_notify.each do |user|
                # user search to reference creation of notification 
                User.find(user).notifications.create(
                    purpose: "new-dish",
                    message: "#{current_user.name} has posted a new dish! Go check it out now!",
                    read: false,
                    data: current_user.id
                )
            end
            redirect_to manager_path(:option => "Manager")
        end
    end

    # instance method for displaying dish on show route
    def show
        # query to find based off parsed id
        @dish = Dish.find(params[:id])
    end

    # method for deleting a dish
    def destroy
        # query to instance dish through parsed id
        dish = Dish.find(params[:id])
        # query to find all notifications through parsed array of order ids
        # array is queried through finding all orders associated with dish id
        Notification.where(data: Order.get_orders_of_dish(params[:id])).destroy_all
        # query to find all orders associated with parsed dish_id
        Order.where(dish_id: params[:id]).destroy_all
        dish.delete

        # check to see who is deleting for correct redirect path
        if current_user.account_type == "admin"
            redirect_back(fallback_location: admin_manage_path)
        else
            flash[:alert] = "#{dish.name} has been deleted successfully."
            redirect_to manager_path(:option => "Manager")
        end
    end
    
    # method for listing a dish - through changing availability attribute boolean
    def list
        # query to instance dish through parsed id
        dish = Dish.find(params[:id])
        dish.available = true
        dish.save
        flash[:alert] = "#{dish.name} has been successfully listed on the market for selling"
        redirect_to manager_path(:option => "Manager")
    end

    # as above but for delisting
    def unlist
        # query to instance dish through parsed id
        dish = Dish.find(params[:id])
        dish.available = false
        dish.save
        flash[:alert] = "#{dish.name} has been succesfully unlisted off the market"
        redirect_to manager_path(:option => "Manager")
    end

    # instance call to display dish details for editing
    def edit
        # query to instance dish through parsed id
        @dish = Dish.find(params[:id])
        render layout: "dashboard"
    end

    # update method for any changes to dish details as above
    def update
        # query to instance dish through parsed id
        dish = Dish.find(params[:id])
        dish.update(dish_params)
        if dish.valid? && dish.save
            redirect_to manager_path(:option => "Manager")
        else
            flash[:alert] = "Sorry something went wrong, could not update your dish at this time."
            render "edit"
        end
    end


    private
    def dish_params
        params.require(:dish).permit(:name, :category, :about, :price, :image, :ingredients)
    end

end
