class CheckoutController < ApplicationController

    def create

        # assigning correct api_key path for different developments
        if Rails.env.development?
            @api = Rails.application.credentials.dig(:stripe, :public_key)
        end
        if Rails.env.production?
            @api = ENV['STRIPE_PUBLIC_KEY']
        end

        # instancing variables for stripe session
        dish = Dish.find(params[:dish])
        quantity = params[:quantity]
        user = current_user
        if dish.nil?
            redirect_to root_path
            return
        end

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
            success_url: "#{root_url}payment/success",
            cancel_url: "#{root_url}"
        )

        respond_to do |format|
            format.js # render create.js.erb
        end

    end

    # method for instancing last user order after payment successful for auto redirect url
    def success
        user = current_user
        @order_id = user.last_order.id
    end

end
