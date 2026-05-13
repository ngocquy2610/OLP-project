class StripeConnectsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = current_user

    begin
      if user.stripe_account_id.blank?
        account = Stripe::Account.create({
          type: "standard",
          email: user.email
        })

        user.update!(stripe_account_id: account.id)
      end

      account_link = Stripe::AccountLink.create({
        account: user.stripe_account_id,
        refresh_url: refresh_stripe_connects_url,
        return_url: return_stripe_connects_url,
        type: "account_onboarding"
      })

      redirect_to account_link.url, allow_other_host: true

    rescue Stripe::StripeError => e
      redirect_to edit_user_registration_path, alert: I18n.t("messages.stripe.connect_error", error: e.message)
    end
  end

  def return
    redirect_to edit_user_registration_path, notice: I18n.t("messages.stripe.connected")
  end

  def refresh
    redirect_to edit_user_registration_path, alert: I18n.t("messages.stripe.session_expired")
  end
end
