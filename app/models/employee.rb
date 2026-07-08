class Employee < ApplicationRecord
  has_many :meeting_participants, dependent: :destroy
  has_many :meetings, through: :meeting_participants

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  scope :alphabetical, -> { order(:name) }
end
