class CreateFavouritesListItems < ActiveRecord::Migration[5.2]
  def change
    create_table :favourites_list_items do |t|
      t.references :user, foreign_key: true
      t.references :favourites_list, foreign_key: true

      t.timestamps
    end
  end
end
