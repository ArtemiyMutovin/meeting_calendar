class Meeting < ApplicationRecord
  has_many :meeting_participants, dependent: :destroy
  has_many :employees, -> { order(:name) }, through: :meeting_participants

  validates :title, presence: true
  validates :starts_at, :ends_at, presence: true
  validate :ends_after_starts
  validate :at_least_two_participants
  validate :no_participant_conflicts

  # Встречи в пределах дня [date 00:00, date+1 00:00)
  scope :on_day, ->(date) {
    where(starts_at: date.beginning_of_day..date.end_of_day)
      .order(:starts_at)
  }

  # Встречи в пределах недели, начинающейся с monday
  scope :in_week, ->(monday) {
    range = monday.beginning_of_day..(monday + 6.days).end_of_day
    where(starts_at: range).order(:starts_at)
  }

  # Возвращает встречи, которые пересекаются по времени с [starts_at, ends_at)
  # для заданного набора сотрудников, исключая саму встречу.
  def self.conflicting_for(employee_ids, starts_at, ends_at, exclude_id: nil)
    scope = joins(:meeting_participants)
              .where(meeting_participants: { employee_id: employee_ids })
              .where("meetings.starts_at < ? AND meetings.ends_at > ?", ends_at, starts_at)
    scope = scope.where.not(id: exclude_id) if exclude_id
    scope.distinct
  end

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "должно быть позже времени начала") if ends_at <= starts_at
  end

  def at_least_two_participants
    if employees.size < 2
      errors.add(:base, "Во встрече должно быть минимум два участника")
    end
  end

  def no_participant_conflicts
    return if starts_at.blank? || ends_at.blank? || ends_at <= starts_at

    ids = employees.map(&:id)
    return if ids.empty?

    conflicts = self.class.conflicting_for(ids, starts_at, ends_at, exclude_id: id)

    conflicts.each do |meeting|
      busy = meeting.employees.where(id: ids)
      busy.each do |emp|
        errors.add(:base,
          "#{emp.name} уже занят(а) на встрече «#{meeting.title}» " \
          "(#{meeting.starts_at.strftime('%d.%m %H:%M')}–#{meeting.ends_at.strftime('%H:%M')})")
      end
    end
  end
end
