class ReviewController < ApplicationController

    def create
        chef = User.find(params[:chef_id])
        review = chef.reviews.create(
            rating: params[:rating],
            comments: params[:comments],
            left_by: current_user.id
        )
        if review.valid? && review.save
            order = Order.find(params[:order])
            order.reviewed = true
            order.save
            redirect_to order_summary_path(order)
        end
    end

end
