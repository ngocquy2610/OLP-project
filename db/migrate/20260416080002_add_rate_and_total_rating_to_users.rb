class AddRateAndTotalRatingToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :rate, :float
    add_column :users, :total_rating, :integer
  end
end
