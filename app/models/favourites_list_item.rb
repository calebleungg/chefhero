class FavouritesListItem < ApplicationRecord
    belongs_to :user
    belongs_to :favourites_list

end
