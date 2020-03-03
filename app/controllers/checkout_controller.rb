class CheckoutController < ApplicationController

    def create

        dish = Dish.find(params[:dish])
        quantity = params[:quantity]

        user = current_user
        last_order = user.orders[-1]

        if dish.nil?
            redirect_to root_path
            return
        end
        Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

        #setting up stripe session for payment
        @session = Stripe::Checkout::Session.create(
            payment_method_types: ['card'],
            line_items: [{
                name: dish.name,
                description: dish.about,
                amount: (dish.price * 100).to_i,
                currency: 'aud',
                quantity: quantity
            }],
            payment_intent_data: {
                metadata: {
                    user_id: current_user.id,
                    dish_id: dish.id,
                    quantity: quantity
                }
            },
            success_url: "#{root_url}order/summary/#{(last_order.id+1)}",
            cancel_url: "#{root_url}"
        )

        respond_to do |format|
            format.js # render create.js.erb
        end

    end

end
