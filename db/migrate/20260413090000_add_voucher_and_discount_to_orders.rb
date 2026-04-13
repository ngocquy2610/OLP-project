class AddVoucherAndDiscountToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :voucher, foreign_key: true, null: true
    add_column :orders, :discount, :decimal, precision: 12, scale: 2, default: 0.0, null: false
  end
end
