class Lesson < ApplicationRecord
  # Nếu bạn dùng course:references
  belongs_to :topic
  has_many :practices, dependent: :destroy

  validates :name, presence: true
end
