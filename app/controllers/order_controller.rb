require 'geocoder'
require "date_format"

class OrderController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def create        
        payment_id = params[:data][:object][:payment_intent]
        payment = Stripe::PaymentIntent.retrieve(payment_id)

        dish = Dish.find(payment.metadata.dish_id)
        user = User.find(payment.metadata.user_id)
        order = user.orders.create(
            quantity: payment.metadata.quantity, 
            dish_id: dish.id, 
            revenue: dish.price,
            status: "placed",
            reviewed: false
        )

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
        @orders = current_user.orders.order("created_at DESC")
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

