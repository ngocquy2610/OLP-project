class AddTopicIdToLessons < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:lessons, :topic_id)
      add_column :lessons, :topic_id, :integer
    end
  end
end
