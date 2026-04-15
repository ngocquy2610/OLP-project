class AddRateToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :rate, :float, default: 0.0
  end
end
