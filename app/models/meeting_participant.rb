class MeetingParticipant < ApplicationRecord
  belongs_to :meeting
  belongs_to :employee

  validates :employee_id, uniqueness: { scope: :meeting_id }

  # Время дублируется из встречи — на нём стоит exclusion constraint
  # no_overlapping_meetings, гарантирующий отсутствие накладок в БД.
  before_validation :copy_time_from_meeting

  private

  def copy_time_from_meeting
    return unless meeting

    self.starts_at = meeting.starts_at
    self.ends_at = meeting.ends_at
  end
end
