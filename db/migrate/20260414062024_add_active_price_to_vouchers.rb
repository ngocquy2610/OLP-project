class AddActivePriceToVouchers < ActiveRecord::Migration[8.1]
  def change
    add_column :vouchers, :active_price, :decimal
  end
end
