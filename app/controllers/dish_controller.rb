class DishController < ApplicationController

    def new
        @dish = Dish.new
    end

    def create
        @dish = current_user.dishes.create(dish_params)
        @dish.image.attach(params[:dish][:image])
        @dish.available = true
        if @dish.valid? && @dish.save
            redirect_to manager_path(:option => "Manager")
        end
    end

    def show
        @dish = Dish.find(params[:id])
    end

    def destroy
        dish = Dish.find(params[:id])
        dish.delete
        flash[:alert] = "#{dish.name} has been deleted successfully."
        redirect_to manager_path(:option => "Manager")
    end
    
    def list
        dish = Dish.find(params[:id])
        dish.available = true
        dish.save
        flash[:alert] = "#{dish.name} has been successfully listed on the market for selling"
        redirect_to manager_path(:option => "Manager")
    end

    def unlist
        dish = Dish.find(params[:id])
        dish.available = false
        dish.save
        flash[:alert] = "#{dish.name} has been succesfully unlisted off the market"
        redirect_to manager_path(:option => "Manager")
    end

    def edit
        @dish = Dish.find(params[:id])
        render layout: "dashboard"
    end

    def update
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
