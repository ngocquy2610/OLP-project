namespace :exchange_rate do
  desc "Cập nhật tỷ giá VND/USD từ API và lưu vào file JSON"
  task update: :environment do
    ExchangeRateService.update_rates
    puts "--- Đã cập nhật tỷ giá lúc #{Time.now} in #{ExchangeRateService::FILE_PATH} ---"
  end
end
