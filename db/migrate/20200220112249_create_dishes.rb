class CreateDishes < ActiveRecord::Migration[5.2]
  def change
    create_table :dishes do |t|
      t.string :name, null:false
      t.string :category
      t.string :about
      t.numeric :price, null:false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
