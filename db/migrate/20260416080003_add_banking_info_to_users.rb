class AddBankingInfoToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :bank_name, :string
    add_column :users, :bank_account_number, :string
    add_column :users, :bank_account_name, :string
  end
end
