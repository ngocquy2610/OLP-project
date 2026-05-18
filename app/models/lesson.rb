class Lesson < ApplicationRecord
  belongs_to :topic
  has_many :practices, dependent: :destroy
  has_many :practice_attempts, dependent: :destroy

  validates :name, presence: true
  has_one_attached :video
  attr_accessor :video_blob_signed_id

  def enqueue_video_attachment
    return if video_blob_signed_id.blank? # if there is no new video uploaded, do not enqueue the job.

    AttachVideoJob.perform_later(id, video_blob_signed_id)
  end
end
