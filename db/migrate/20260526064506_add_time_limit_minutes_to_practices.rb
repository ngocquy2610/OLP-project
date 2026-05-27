class AddTimeLimitMinutesToPractices < ActiveRecord::Migration[8.1]
  def change
    add_column :practices, :time_limit_minutes, :integer
  end
end
