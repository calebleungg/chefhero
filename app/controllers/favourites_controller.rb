class FavouritesController < ApplicationController

    # method for adding a chef to a user's favourites list
    def add
        user = current_user
        # check if current user has existing favourites list record- creates if nil
        if user.favourites_list == nil
            favourites = user.create_favourites_list
        else
            favourites = user.favourites_list
        end
        favourites.favourites_list_items.create(user_id: params[:id])
        # validation check
        if favourites.valid? && favourites.save
            redirect_back(fallback_location: user_path(params[:id]))
        end
    end

    # method for removing a chef froma  user's favourites list
    def remove
        current_user.favourites_list.favourites_list_items.where(user_id: params[:id]).first.destroy
        redirect_back(fallback_location: user_path(params[:id]))
    end

end
