require 'geocoder'
require "date_format"

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
        begin
            @address_coordinates = Geocoder.search(@chef.address.display_full).first.coordinates.reverse
        rescue
            @address_coordinates = Geocoder.search("Brisbane Australia").first.coordinates.reverse
        rescue
        end
    end

    def history
        @orders = Order.where(user_id: params[:id]).reverse
    end

    def ready
        order = Order.find(params[:id])
        order.status = "ready"
        if order.save
            redirect_to orders_manager_path(:option => "Orders")
        end
    end

    def collected
        order = Order.find(params[:id])
        order.status = "collected"
        if order.save
            redirect_to orders_manager_path(:option => "Orders")
        end
    end

    def manager

        @orders_placed = Order.where(dish_id: current_user.get_dish_ids, status:"placed").order("created_at DESC")
        @orders_ready = Order.where(dish_id: current_user.get_dish_ids, status:"ready").order("created_at DESC")
        @orders_collected = Order.where(dish_id: current_user.get_dish_ids, status:"collected").order("updated_at DESC").limit(10)
        @orders_today = 0
        @daily_total = 0

        for order in Order.where(dish_id: current_user.get_dish_ids).order("created_at DESC")
            if order.created_at.in_time_zone('Australia/Brisbane').day == Time.now.in_time_zone('Australia/Brisbane').day
                @daily_total += order.get_total
                @orders_today += 1
            end
        end

        render layout: "dashboard"
    end

    def chef_history
        @orders = Order.where(dish_id: current_user.get_dish_ids, status:"collected").order("updated_at DESC")

        render layout: "dashboard"
    end

    def earnings
        @orders = current_user.get_total_orders
        @net_sales = current_user.get_total_sales
        @withdrawals = current_user.withdrawals.reverse
        @available_to_withdraw = @net_sales - current_user.get_withdrawn_total
        render layout: "dashboard"
    end

end

