class WithdrawalsController < ApplicationController
  before_action :authenticate_user!

  def create
    usd_rate = (JSON.parse(File.read(Rails.root.join('public','exchange_rate.json')))['rate'] rescue nil)
    if current_user.stripe_account_id.blank?
      return redirect_to profile_path, alert: "LỖI: Bạn cần liên kết Stripe Account ID trước khi rút tiền."
    end

    teacher = current_user
    amount_to_withdraw = teacher.balance

    if amount_to_withdraw <= 0
      return redirect_to profile_path, alert: "Số dư của bạn bằng 0, không thể rút tiền."
    end

    if teacher.stripe_account_id.blank?
      return redirect_to profile_path, alert: "Bạn chưa liên kết tài khoản Stripe để nhận tiền."
    end

    begin
      transfer = Stripe::Transfer.create({
        amount: (amount_to_withdraw * usd_rate * 100).to_i,
        currency: 'usd',
        destination: teacher.stripe_account_id,
        description: "Rút tiền doanh thu từ nền tảng OLP - Giáo viên: #{teacher.fullname}"
      })

      if transfer.id.present?
        teacher.update!(balance: 0)

        redirect_to profile_path, notice: "Yêu cầu rút tiền thành công! Tiền sẽ sớm chuyển về ngân hàng của bạn."
      end

    rescue Stripe::StripeError => e
      redirect_to profile_path, alert: "Lỗi thanh toán: #{e.message}"
      Rails.logger.error "Stripe Transfer Error for User #{teacher.id} (#{teacher.email}): #{e.message}"
    end
  end
end