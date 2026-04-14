class AddTagToCourse < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :tag, :string
  end
end
