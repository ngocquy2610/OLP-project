class UserProfile < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :fullname, :string
    add_column :users, :phone, :string
    add_column :users, :address, :text
    # 'default: 0' --> student
    add_column :users, :role, :integer, default: 0
  end
end
