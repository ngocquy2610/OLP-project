class RemovePercentageFromExamAttempts < ActiveRecord::Migration[8.1]
  def change
    remove_column :exam_attempts, :percentage, :float
  end
end
