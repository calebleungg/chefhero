class CheckoutController < ApplicationController

    def create

        # if check here to determine env by going Rails.env.development? then set true if so then pass true to run appropriate key call in create.js

        if Rails.env.development?
            @api = Rails.application.credentials.dig(:stripe, :public_key)
        end

        if Rails.env.production?
            @api = ENV['STRIPE_PUBLIC_KEY']
        end

        dish = Dish.find(params[:dish])
        quantity = params[:quantity]


        user = current_user
        last_order = user.orders.order("created_at DESC")[0].id.to_i

        if dish.nil?
            redirect_to root_path
            return
        end

        # Stripe.api_key = Rails.application.credentials.stripe[:secret_key]

        #setting up stripe session for payment
        @session = Stripe::Checkout::Session.create(
            payment_method_types: ['card'],
            line_items: [{
                name: dish.name,
                description: dish.about,
                images: ["#{dish.get_image.service_url}"],
                amount: (dish.price * 100).to_i,
                currency: 'aud',
                quantity: quantity
            }],
            payment_intent_data: {
                metadata: {
                    user_id: user.id,
                    dish_id: dish.id,
                    quantity: quantity
                }
            },
            success_url: "#{root_url}order/summary/#{(last_order+1)}",
            cancel_url: "#{root_url}"
        )

        respond_to do |format|
            format.js # render create.js.erb
        end

    end

end
