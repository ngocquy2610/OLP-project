module TurboFrameFlashable
  extend ActiveSupport::Concern

  included do
    after_action :inject_flash_for_turbo_frame
  end

  private

  def inject_flash_for_turbo_frame
    return unless turbo_frame_request?
    return if flash.empty?
    return unless response.media_type == "text/html"
    return if response.body.blank?

    flash_stream = view_context.turbo_stream.replace(
      "flash_messages",
      view_context.render("layouts/flash")
    )

    response.body = "#{flash_stream}#{response.body}"
  end
end
