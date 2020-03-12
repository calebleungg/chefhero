require 'geocoder'
require "date_format"

class OrderController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    # method for creating an order
    def create
        # requiring details of order from webhook after successful strip checkout        
        payment_id = params[:data][:object][:payment_intent]
        payment = Stripe::PaymentIntent.retrieve(payment_id)

        # queries for instancing models through parsed webhook metadata
        dish = Dish.find(payment.metadata.dish_id)
        user = User.find(payment.metadata.user_id)

        # creating order through user relationship
        order = user.orders.create(
            quantity: payment.metadata.quantity, 
            dish_id: dish.id, 
            revenue: dish.price,
            status: "placed",
            reviewed: false
        )

        chef = dish.get_chef
        # validating info
        if order.valid? && order.save
            # creating notification for chef for order placement
            chef.notifications.create(
                purpose: "order-placed",
                message: "A new order has been placed by #{user.name}. For #{order.quantity.to_i} x #{order.get_dish.name}. Go manage now!",
                read: false,
                data: order.id
            )
            redirect_to order_summary_path(order.id)
        end

    end

    # method for displaying single order summary
    def summary

        # checking if path received from notification click- if so then marking read and destroying
        if params[:notification_id]
            Notification.find(params[:notification_id]).destroy
            # page refresh to update icon number
            redirect_to order_summary_path(params[:id])
        else
            # instancing order details for view display
            @order = Order.find(params[:id])
            @dish = Dish.find(@order.dish_id)
            @chef = @dish.get_chef
            @total = @order.quantity * @dish.price
            begin
                @address_coordinates = Geocoder.search(@chef.address.display_full).first.coordinates.reverse
            rescue
                # hard coding coordinates to brisbane default if user inputted throws error
                @address_coordinates = Geocoder.search("Brisbane Australia").first.coordinates.reverse
            rescue
            end
        end

    end

    # method displaying instanced order history for a general user (foodie)
    def history
        @orders = Order.filter_by_date(current_user, params[:from_date], params[:to_date], nil).order("created_at DESC")
    end

    # method changing an order status to "ready"
    def ready 
        order = Order.find(params[:id])
        order.status = "ready"
        user = User.find(order.user_id)
        # verification check
        if order.save
            # creating a notification for user displaying order ready message
            user.notifications.create(
                purpose: "order-ready",
                message: "Your order ##{order.id} (#{order.get_dish.name}) is ready to be picked up. Go see directions now!",
                read: false,
                data: order.id
            )
            redirect_to orders_manager_path(:option => "Orders")
        end
    end

    # method changing an order status to "collected"
    def collected
        order = Order.find(params[:id])
        order.status = "collected"
        user = User.find(order.user_id)
        # verification check
        if order.save
            # creating a notification for user as above
            user.notifications.create(
                purpose: "review-request",
                message: "We hope you enjoyed your food! Make sure to give #{order.get_chef.first_name} a review now!",
                read: false,
                data: order.id
            )
            redirect_to orders_manager_path(:option => "Orders")
        end
    end

    # method for managing chef orders
    def manager
        # checking if path received from notification click- if so then marking read and destroying
        if params[:notification_id]
            Notification.find(params[:notification_id]).destroy
            redirect_to orders_manager_path(:option => "Manager")
        else
            # instancing orders in correct progression column to be managed
            # obtaining orders through parsed array of dish ids associated with user (chef) dishes
            # last query to order by newest created
            @orders_placed = Order.where(dish_id: current_user.get_dish_ids, status:"placed").order("created_at DESC")
            @orders_ready = Order.where(dish_id: current_user.get_dish_ids, status:"ready").order("created_at DESC")
            @orders_collected = Order.where(dish_id: current_user.get_dish_ids, status:"collected").order("updated_at DESC").limit(10)
            @orders_today = 0
            @daily_total = 0
    
            # instancing small order history list
            for order in Order.where(dish_id: current_user.get_dish_ids).order("created_at DESC")
                # check comparing order created is equal to today of summing daily revenue total
                if order.created_at.in_time_zone('Australia/Brisbane').day == Time.now.in_time_zone('Australia/Brisbane').day
                    @daily_total += order.get_total
                    @orders_today += 1
                end
            end
            render layout: "dashboard"
        end
    end

    # method for instancing order history- filtered by date between parsed dates if given
    def chef_history
        @orders = Order.filter_by_date(current_user, params[:from_date], params[:to_date], current_user.get_dish_ids).order("updated_at DESC")
        render layout: "dashboard"
    end

    # method for display earning details
    def earnings
        @orders = current_user.get_total_orders
        @net_sales = current_user.get_total_sales
        @withdrawals = current_user.withdrawals.reverse
        @available_to_withdraw = @net_sales - current_user.get_withdrawn_total
        render layout: "dashboard"
    end

    # method querying notifications with matching data ids then destroying
    # querying all associated orders with parsed id to destroy also
    def delete
        Notification.where(data: params[:id]).destroy_all
        Order.find(params[:id]).destroy
        redirect_back(fallback_location: admin_manage_path)
    end

end

