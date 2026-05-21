namespace :exchange_rate do
  desc I18n.t("tasks.exchange_rate.update.desc")
  task update: :environment do
    ExchangeRateService.update_rates
    puts I18n.t(
      "tasks.exchange_rate.update.done",
      time: Time.current,
      file_path: ExchangeRateService::FILE_PATH
    )
  end
end
