class CreateCartItems < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      # quantity removed: each course can only be bought once

      t.timestamps
    end
  end
end
