module LocaleSwitchable
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
  end

  private

  def switch_locale(&action)
    if params[:locale].present?
      session[:locale] = params[:locale]
    end

    locale = session[:locale] || I18n.default_locale

    I18n.with_locale(locale, &action)
  end
end
