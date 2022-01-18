class Task < ApplicationRecord
  before_validation :set_nameless_name
  validates :name, presence: true,length: {maximum:30}
  validate :validate_name_not_including_comma

  belongs_to :user

  scope :recent, -> { order(created_at: :desc)}

  private
  def validate_name_not_including_comma
    errors.add(:name, 'にカンマをふくめることはできません') if name&.include?(',')
  end

  def set_nameless_name
    self.name = '名前なし' if name.blank?
  end
end
