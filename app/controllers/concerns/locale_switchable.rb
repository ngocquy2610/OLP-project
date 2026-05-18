module LocaleSwitchable
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale # run both before and after the action, to set the locale for the duration of the request
  end

  private

  def switch_locale(&action)
    if params[:locale].present? # check the param from UI (the dropdown in the header)
      session[:locale] = params[:locale] # set the session locale follow by params locale
    end

    locale = session[:locale] || I18n.default_locale # set the locale follow by session locale or default (En)

    I18n.with_locale(locale, &action) # translation
  end
end
