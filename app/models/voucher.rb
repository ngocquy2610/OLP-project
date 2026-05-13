class Voucher < ApplicationRecord
  before_validation :upcase_code

  validates :code, presence: true, uniqueness: true

  validates :discount_percent, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

  def usable?
    active? &&
    (expires_at.nil? || expires_at > Time.current) &&
    (usage_limit.nil? || used_count < usage_limit)
  end

  private

  def upcase_code
    self.code = code.upcase if code.present?
  end
end
