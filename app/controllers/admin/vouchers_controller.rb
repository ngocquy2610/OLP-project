class Admin::VouchersController < Admin::BaseController
  def index
    @vouchers = Voucher.order(created_at: :desc)
  end

  def new
    @voucher = Voucher.new
  end

  def create
    @voucher = Voucher.new(voucher_params)
    
    if @voucher.save
      redirect_to admin_vouchers_path, notice: "Voucher was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def voucher_params
    params.require(:voucher).permit(:code, :discount_percent, :expires_at, :usage_limit, :active, :active_price)
  end
end