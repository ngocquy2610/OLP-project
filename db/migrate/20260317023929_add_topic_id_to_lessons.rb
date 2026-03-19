class AddTopicIdToLessons < ActiveRecord::Migration[8.1]
  def change
    add_column :lessons, :topic_id, :integer
  end
end
