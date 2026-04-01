class RemoveVideoFromLessons < ActiveRecord::Migration[8.1]
  def change
    # Remove legacy `video` column (conflicts with ActiveStorage's has_one_attached :video)
    if column_exists?(:lessons, :video)
      remove_column :lessons, :video, :string
    end
  end
end
