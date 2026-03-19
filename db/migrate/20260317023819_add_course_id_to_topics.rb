class AddCourseIdToTopics < ActiveRecord::Migration[8.1]
  def change
    add_column :topics, :course_id, :integer
  end
end
