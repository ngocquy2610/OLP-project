class WithdrawalsController < ApplicationController
  before_action :authenticate_user!

  def create
    usd_rate = (JSON.parse(File.read(Rails.root.join("public", "exchange_rate.json")))["rate"] rescue nil)
    if current_user.stripe_account_id.blank?
      return redirect_to profile_path, alert: I18n.t("messages.withdrawals.stripe_required")
    end

    teacher = current_user
    amount_to_withdraw = teacher.balance

    if amount_to_withdraw <= 0
      return redirect_to profile_path, alert: I18n.t("messages.withdrawals.zero_balance")
    end

    if teacher.stripe_account_id.blank?
      return redirect_to profile_path, alert: I18n.t("messages.withdrawals.stripe_receive_required")
    end

    begin
      transfer = Stripe::Transfer.create({
        amount: (amount_to_withdraw * usd_rate * 100).to_i,
        currency: "usd",
        destination: teacher.stripe_account_id,
        description: I18n.t("messages.withdrawals.transfer_description", teacher: teacher.fullname)
      })

      if transfer.id.present?
        teacher.update!(balance: 0)

        redirect_to profile_path, notice: I18n.t("messages.withdrawals.success")
      end

    rescue Stripe::StripeError => e
      redirect_to profile_path, alert: I18n.t("messages.withdrawals.payment_error", error: e.message)
      Rails.logger.error "Stripe Transfer Error for User #{teacher.id} (#{teacher.email}): #{e.message}"
    end
  end
end
