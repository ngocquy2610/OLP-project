require 'net/http'
require 'uri'

class GmoPaymentService
  # Dùng chính xác URL từ cụm server pt01 trong Dashboard của bạn
  ENTRY_URL = "https://pt01.mul-pay.jp/payment/EntryTran.idPass"
  EXEC_URL  = "https://pt01.mul-pay.jp/payment/ExecTran.idPass"

  # Accept either a frontend Token (recommended) or raw card details as fallback.
  # Prefer calling with token: GmoPaymentService.new(order, token: '...')
  def initialize(order, token: nil, card_no: nil, expire: nil, security_code: nil)
    @order = order
    @token = token.presence

    if @token.nil?
      @card_no = card_no.to_s.gsub(/[\s-]/, '') if card_no
      @expire = expire.to_s
      @security_code = security_code.to_s
    end

    @shop_id = ENV['GMO_SHOP_ID'] || 'tshop00076628'
    @shop_pass = ENV['GMO_SHOP_PASS'] || 'rdu6mrmk' # Ensure env var exists in production
  end

  def charge_card
    # ==========================================
    # BƯỚC 1: Gọi EntryTran (Khởi tạo giao dịch)
    # ==========================================
    entry_params = {
      'ShopID'   => @shop_id,
      'ShopPass' => @shop_pass,
      'OrderID'  => "OLP-#{@order.id}-#{Time.now.to_i}", # Đảm bảo ID không trùng lặp
      'JobCd'    => 'CAPTURE', # Lấy tiền ngay
      'Amount'   => @order.order_items.sum(:price).to_i #check to_s
    }
    
    entry_response = call_api(ENTRY_URL, entry_params)
    
    # Nếu báo lỗi ngay từ vòng gửi xe
    if entry_response['ErrCode']
      return { success: false, error: "Lỗi khởi tạo: #{entry_response['ErrInfo']}" }
    end

    # ==========================================
    # BƯỚC 2: Gọi ExecTran (Chốt đơn) — use Token if available
    # ==========================================
    exec_params = {
      'AccessID'   => entry_response['AccessID'],
      'AccessPass' => entry_response['AccessPass'],
      'OrderID'    => entry_params['OrderID'],
      'Method'     => '1'
    }

    if @token.present?
      # Use frontend token (recommended) — do NOT send raw card numbers from server
      exec_params['Token'] = @token
    else
      exec_params['CardNo']       = @card_no
      exec_params['Expire']       = @expire
      exec_params['SecurityCode'] = @security_code
    end

    exec_response = call_api(EXEC_URL, exec_params)

    # In ra Terminal để mình xem nó trả về gì
    puts "=== RAW GMO EXEC RESPONSE ==="
    puts exec_response.inspect
    puts "============================="

    if exec_response['ErrCode']
      { success: false, error: "Giao dịch bị từ chối: #{exec_response['ErrInfo']}" }
    else
      # Nếu không có ErrCode nghĩa là trừ tiền thành công!
      { success: true, transaction_id: exec_response['TranID'] }
    end

  rescue => e
    Rails.logger.error "GMO Service Error: #{e.message}"
    { success: false, error: "Lỗi hệ thống: #{e.message}" }
  end

  private

  # Hàm dùng chung để bắn API (Vì API cũ dùng form-data thay vì JSON)
  def call_api(url, params)
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(params) 

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(request)
    end
    
    # Cực kỳ quan trọng: API cũ trả về chuỗi kiểu "Key1=Value1&Key2=Value2"
    # Lệnh này sẽ biến nó thành Hash của Ruby để dễ xài.
    Rack::Utils.parse_nested_query(response.body)
  end
end
