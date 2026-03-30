class AddLessonIdToPractices < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:practices, :lesson_id)
      add_column :practices, :lesson_id, :integer
    end
  end
end
