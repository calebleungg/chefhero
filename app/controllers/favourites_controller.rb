class FavouritesController < ApplicationController

    def add
        user = current_user
        if user.favourites_list == nil
            favourites = user.favourites_list.new
        else
            favourites = user.favourites_list
        end
        favourites.favourites_list_items.create(user_id: params[:id])
        if favourites.valid? && favourites.save
            redirect_back(fallback_location: user_path(params[:id]))
        end
    end

    def remove
        current_user.favourites_list.favourites_list_items.where(user_id: params[:id]).first.destroy
        redirect_back(fallback_location: user_path(params[:id]))
    end

end
