class Lesson < ApplicationRecord
  belongs_to :topic
  has_many :practices, dependent: :destroy
  has_many :practice_attempts, dependent: :destroy

  validates :name, presence: true
  has_one_attached :video
  attr_accessor :video_blob_signed_id # like create column but not save in db. Research more
  # reader - get value of video_blob_signed_id, writer - set value of video_blob_signed_id

  def enqueue_video_attachment
    return if video_blob_signed_id.blank? # if there is no new video uploaded, do not enqueue the job.

    AttachVideoJob.perform_later(id, video_blob_signed_id)
  end
end

# setor - getor - khởi tạo và gán giá trị cho biến instance (instance variable) trong controller, để có thể sử dụng trong view.
