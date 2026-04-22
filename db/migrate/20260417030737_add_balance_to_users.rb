class AddBalanceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :balance, :integer, default: 0
  end
end
