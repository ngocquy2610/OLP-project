class AddCourseIdToTopics < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:topics, :course_id)
      add_column :topics, :course_id, :integer
    end
  end
end
