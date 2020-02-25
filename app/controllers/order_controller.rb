require 'geocoder'

class OrderController < ApplicationController

    def create
        dish = Dish.find(params[:dish])
        user = current_user
        order = user.orders.create(quantity: params[:quantity], dish_id: dish.id)
        order.status = "placed"
        if order.valid? && order.save
            redirect_to order_summary_path(order.id)
        end
    end

    def summary
        @order = Order.find(params[:id])
        @dish = Dish.find(@order.dish_id)
        @chef = @dish.get_chef
        @total = @order.quantity * @dish.price
        @address_coordinates = Geocoder.search(@chef.address.display_full).first.coordinates.reverse
    end

    def history
        @orders = Order.where(user_id: params[:id])
    end

end

