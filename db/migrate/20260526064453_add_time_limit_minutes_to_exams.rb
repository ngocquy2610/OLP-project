class AddTimeLimitMinutesToExams < ActiveRecord::Migration[8.1]
  def change
    add_column :exams, :time_limit_minutes, :integer
  end
end
