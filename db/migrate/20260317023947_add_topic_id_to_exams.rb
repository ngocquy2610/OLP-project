class AddTopicIdToExams < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:exams, :topic_id)
      add_column :exams, :topic_id, :integer
    end
  end
end
