class AddStatusToExamAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :exam_attempts, :percentage, :float
    add_column :exam_attempts, :completed, :boolean
  end
end
