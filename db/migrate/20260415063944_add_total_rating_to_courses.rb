class AddTotalRatingToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :total_rating, :integer
  end
end
