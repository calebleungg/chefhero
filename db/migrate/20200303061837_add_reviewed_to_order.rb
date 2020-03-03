class AddReviewedToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :reviewed, :boolean
  end
end
