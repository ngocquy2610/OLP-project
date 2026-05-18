module TurboFrameFlashable
  extend ActiveSupport::Concern

  included do
    after_action :inject_flash_for_turbo_frame
  end

  private

  def inject_flash_for_turbo_frame
    return unless turbo_frame_request? # check turbo request (from turbo frame) to avoid inject flash for normal request
    return if flash.empty? # check if there is any flash message to inject, if not, skip the injection
    return unless response.media_type == "text/html" # check if the response is HTML, if not, skip the injection
    return if response.body.blank? # check if the response body is blank, if so, skip the injection

    flash_stream = view_context.turbo_stream.update(
      "flash_messages",
      view_context.render("layouts/flash")
    )
    # view_context: a function that allows us to access the view context from the controller
    response.body = "#{flash_stream}#{response.body}" # prepend the flash stream to the response body
  end
end
