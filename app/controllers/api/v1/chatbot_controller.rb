class Api::V1::ChatbotController < ApplicationController
  before_action :authenticate_user!, except: :index

  def index
    render json: { message: "Chatbot API is ready" }
  end

  def create
    message = chat_params[:message].to_s.strip # strip - remove blank
    return render json: { error: "message is required" }, status: :unprocessable_entity if message.blank?

    chat_history_record = current_user.chat_history || current_user.create_chat_history!(chat_history: "[]")
    chat_history = ChatbotService.load_chat_history(current_user)

    chatbot_result = ChatbotService.process_message(
      message: message,
      chat_history: chat_history,
      user_id: current_user.id
    )

    chat_history_record.update!(chat_history: chatbot_result[:chat_history].to_json)

    render json: chatbot_result
  rescue ChatbotService::Error => e
    render json: { error: e.message }, status: :service_unavailable
  rescue StandardError => e
    Rails.logger.error "Chatbot controller error: #{e.message}"
    render json: { error: "Chatbot is unavailable" }, status: :service_unavailable
  end

  private

  def chat_params
    return params.require(:chatbot).permit(:message) if params[:chatbot].present?
    return params.require(:chat).permit(:message) if params[:chat].present?

    params.permit(:message)
  end
end