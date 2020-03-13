class ReviewController < ApplicationController

    # method for creating a review
    def create
        # find query of parsed id then creating review
        chef = User.find(params[:chef_id])
        review = chef.reviews.create(
            rating: params[:rating],
            comments: params[:comments],
            left_by: current_user.id.to_i
        )
        # validation check
        if review.valid? && review.save
            # after validation- changes related order attribute reviewed to true (removing review option)
            order = Order.find(params[:order])
            order.reviewed = true
            order.save
            redirect_to order_summary_path(order)
        end
    end

    # single query search off parsed id to destroy
    def delete
        Review.find(params[:id]).destroy
        redirect_back(fallback_location: admin_manage_path)
    end

end
