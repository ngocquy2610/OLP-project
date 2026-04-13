class CreateVouchers < ActiveRecord::Migration[8.1]
  def change
    create_table :vouchers do |t|
      t.string :code
      t.integer :discount_percent
      t.datetime :expires_at
      t.integer :usage_limit
      t.integer :used_count, default: 0
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :vouchers, :code, unique: true
  end
end
