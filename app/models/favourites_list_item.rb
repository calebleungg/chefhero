class FavouritesListItem < ApplicationRecord
    belongs_to :user
    belongs_to :favourites_list

    # method for returning user favourited
    def get_user
        return User.find(self.user_id)
    end
    
end
