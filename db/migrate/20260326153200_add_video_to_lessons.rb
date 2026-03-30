class AddVideoToLessons < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:lessons, :video)
      add_column :lessons, :video, :string
    end
  end
end
