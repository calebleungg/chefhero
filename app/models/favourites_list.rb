class FavouritesList < ApplicationRecord
	belongs_to :user
	has_many :favourites_list_items

end
