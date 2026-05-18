# require 'net/http'
# require 'json'

# class ExchangeRateService
#   API_URL = "https://fxapi.app/api/vnd/usd.json"
#   FILE_PATH = "/home/quynn/Desktop/LTS/OLP-project/exchange_rate.json"

#   def self.update_rates
#     uri = URI.parse(API_URL)
#     response = Net::HTTP.get(uri)
#     data = JSON.parse(response)

#     File.write(FILE_PATH, JSON.pretty_generate(data))

#     Rails.logger.info "Exchange rate updated successfully at #{Time.current} in #{FILE_PATH}"
#   rescue => e
#     Rails.logger.error "Failed to update exchange rate: #{e.message}"
#   end
# end

require "net/http"
require "json"

class ExchangeRateService
  API_URL = "https://fxapi.app/api/vnd/usd.json"
  FILE_PATH = "/home/quynn/Desktop/LTS/OLP-project/exchange_rate.json"

  def self.update_rates
    uri = URI.parse(API_URL)

    response = nil
    begin
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)
      end
    rescue OpenSSL::SSL::SSLError => e
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        request = Net::HTTP::Get.new(uri)
        response = http.request(request)
      end
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "HTTP error fetching exchange rates: #{response&.code} #{response&.message}"
    end

    data = JSON.parse(response.body)

    FileUtils.mkdir_p(File.dirname(FILE_PATH))
    File.open(FILE_PATH, "w") do |f|
      f.write(JSON.pretty_generate(data))
    end

    Rails.logger.info "Exchange rate updated successfully at #{Time.current} in #{FILE_PATH}"
  rescue => e
    Rails.logger.error "Failed to update exchange rate: #{e.message}"
  end
end
