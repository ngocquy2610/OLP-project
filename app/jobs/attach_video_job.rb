# app/jobs/attach_video_job.rb
class AttachVideoJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 5

  def perform(lesson_id, signed_blob_id)
    lesson = Lesson.find_by(id: lesson_id)
    return if lesson.blank? || signed_blob_id.blank?

    blob = ActiveStorage::Blob.find_signed(signed_blob_id)
    return if blob.blank?

    lesson.video.purge if lesson.video.attached?
    lesson.video.attach(blob)

    Rails.logger.info("Video attached to lesson #{lesson_id}")
  rescue => e
    Rails.logger.error("Video attachment failed: #{e.message}")
    raise e
  end
end
