class AddTopicIdToExams < ActiveRecord::Migration[8.1]
  def change
    add_column :exams, :topic_id, :integer
  end
end
