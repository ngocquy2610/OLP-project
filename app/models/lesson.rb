class Lesson < ApplicationRecord
  belongs_to :topic
  has_many :practices, dependent: :destroy

  validates :name, presence: true
end
