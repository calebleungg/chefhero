class AddIngredientsToDish < ActiveRecord::Migration[5.2]
  def change
    add_column :dishes, :ingredients, :string
  end
end
