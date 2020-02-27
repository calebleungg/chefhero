class CreateWithdrawals < ActiveRecord::Migration[5.2]
  def change
    create_table :withdrawals do |t|
      t.numeric :amount, null:false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
