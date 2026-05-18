require "net/http"
require "uri"

class GmoPaymentService
  ENTRY_URL = "https://pt01.mul-pay.jp/payment/EntryTran.idPass"
  EXEC_URL  = "https://pt01.mul-pay.jp/payment/ExecTran.idPass"

  def initialize(order, token: nil, card_no: nil, expire: nil, security_code: nil)
    @order = order
    @token = token.presence

    if @token.nil?
      @card_no = card_no.to_s.gsub(/[\s-]/, "") if card_no
      @expire = expire.to_s
      @security_code = security_code.to_s
    end

    @shop_id = ENV["GMO_SHOP_ID"]
    @shop_pass = ENV["GMO_SHOP_PASS"]
  end

  def charge_card
    entry_params = {
      "ShopID"   => @shop_id,
      "ShopPass" => @shop_pass,
      "OrderID"  => "OLP-#{@order.id}-#{Time.now.to_i}", # Đảm bảo ID không trùng lặp
      "JobCd"    => "CAPTURE", # Lấy tiền ngay
      "Amount"   => @order.order_items.sum(:price).to_i
    }

    entry_response = call_api(ENTRY_URL, entry_params) # Gọi API khởi tạo giao dịch để lấy AccessID và AccessPass

    if entry_response["ErrCode"]
      return { success: false, error: "Lỗi khởi tạo: #{entry_response['ErrInfo']}" }
    end

    exec_params = {
      "AccessID"   => entry_response["AccessID"],
      "AccessPass" => entry_response["AccessPass"],
      "OrderID"    => entry_params["OrderID"],
      "Method"     => "1"
    }

    if @token.present?
      exec_params["Token"] = @token
    else
      exec_params["CardNo"]       = @card_no
      exec_params["Expire"]       = @expire
      exec_params["SecurityCode"] = @security_code
    end

    exec_response = call_api(EXEC_URL, exec_params)

    if exec_response["ErrCode"]
      { success: false, error: "Giao dịch bị từ chối: #{exec_response['ErrInfo']}" }
    else
      { success: true, transaction_id: exec_response["TranID"] }
    end

  rescue => e
    Rails.logger.error "GMO Service Error: #{e.message}"
    { success: false, error: "Lỗi hệ thống: #{e.message}" }
  end

  private

  def call_api(url, params)
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(params)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(request)
    end

    Rack::Utils.parse_nested_query(response.body)
  end
end
