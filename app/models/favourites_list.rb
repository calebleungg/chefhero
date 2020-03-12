class FavouritesList < ApplicationRecord
	belongs_to :user
	has_many :favourites_list_items, dependent: :destroy

	# method for returning an array of user id's that have favourited this chef
	def self.return_notif_list(chef)
		# querying all bookmarks made of parsed chef
		chef_bookmarks = FavouritesListItem.where(user_id: chef)

		# iterating through all favourite lists and appending to array if includes chef 
		user_lists = []
		chef_bookmarks.each do |list|
			if user_lists.include?(list.favourites_list_id) == false
				user_lists.push(list.favourites_list_id)
			end
		end

		# querying all favourites lists with parsed array of ids as obtained above
		notif_users = FavouritesList.where(id: user_lists)

		# creating array of all users who need to be notified
		to_notify = []
		notif_users.each do |list|
			to_notify.push(list.user_id)
		end 
		return to_notify
	end
	
end
