class AddLessonIdToPractices < ActiveRecord::Migration[8.1]
  def change
    add_column :practices, :lesson_id, :integer
  end
end
