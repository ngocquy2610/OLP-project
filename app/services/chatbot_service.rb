require "net/http"
require "json"

module ChatbotService
  class Error < StandardError; end

  COURSE_KNOWLEDGE_LIMIT = 100

  def self.load_chat_history(user)
    return [] if user.chat_history&.chat_history.blank?

    JSON.parse(user.chat_history.chat_history)
  rescue JSON::ParserError => e
    Rails.logger.warn "Failed to parse stored chat history for user #{user.id}: #{e.message}"
    []
  end

  def self.process_message(message:, chat_history:, user_id: nil)
    url = ENV["PYTHON_API_URL"]
    raise Error, "PYTHON_API_URL is not configured" if url.blank?

    uri = URI.join(normalized_url(url), "chat")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 10
    http.read_timeout = 30

    request = Net::HTTP::Post.new(uri.request_uri, "Content-Type" => "application/json")
    request.body = {
      user_id: user_id,
      message: message,
      chat_history: chat_history,
      course_knowledge: courses_knowledge
    }.compact.to_json

    response = http.request(request)
    payload = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "Python API error: #{response.code} #{response.body}"
      raise Error, payload["error"].presence || "Python API returned #{response.code}"
    end

    response_text = payload["response"].to_s

    {
      response: response_text,
      chat_history: payload["chat_history"] || append_messages(chat_history, message, response_text)
    }
  rescue JSON::ParserError => e # catch the nearest error.
    Rails.logger.error "Failed to parse Python API response: #{e.message}"
    raise Error, "Invalid response from Python API"
  rescue StandardError => e # other errors
    raise e if e.is_a?(Error)

    Rails.logger.error "Failed to reach Python API: #{e.message}"
    raise Error, "Failed to reach Python API"
  end

  def self.append_messages(chat_history, message, response)
    chat_history + [
      { "role" => "user", "text" => message },
      { "role" => "assistant", "text" => response }
    ]
  end

  def self.normalized_url(url)
    url.end_with?("/") ? url : "#{url}/"
  end

  def self.courses_knowledge
    Course
      .select(:name, :description, :price, :tag, :rate, :total_rating)
      .order(updated_at: :desc)
      .limit(COURSE_KNOWLEDGE_LIMIT)
      .map do |course|
        {
          name: course.name,
          description: course.description,
          price: course.price,
          tag: course.tag,
          rate: course.rate,
          total_rate: course.total_rating
        }
      end
  end
end
