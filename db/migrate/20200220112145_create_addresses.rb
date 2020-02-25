class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :street, null:false
      t.string :suburb
      t.string :city, null:false
      t.string :postcode
      t.string :country, null:false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
