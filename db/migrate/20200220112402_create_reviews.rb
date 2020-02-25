class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.numeric :rating, null:false
      t.string :comments
      t.numeric :left_by, null:false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
