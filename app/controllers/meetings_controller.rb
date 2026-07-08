class MeetingsController < ApplicationController
  def index
    @view = %w[day week].include?(params[:view]) ? params[:view] : "day"
    @date = parse_date(params[:date])

    @meetings =
      if @view == "week"
        Meeting.in_week(@date.beginning_of_week)
      else
        Meeting.on_day(@date)
      end

    @meetings = @meetings.includes(:employees)
  end

  def show
    @meeting = Meeting.includes(:employees).find(params[:id])
  end

  def new
    @meeting = Meeting.new
    @employees = Employee.alphabetical
    set_time_defaults
  end

  def create
    @meeting = Meeting.new(meeting_params)
    read_time_params
    @meeting.starts_at = compose_time(@start_hour, @start_min)
    @meeting.ends_at   = compose_time(@end_hour, @end_min)

    if @meeting.save
      redirect_to @meeting, notice: "Встреча создана."
    else
      render_new_error
    end
  rescue ActiveRecord::StatementInvalid => e
    # Страховка от гонки: валидация могла пройти, но exclusion constraint в БД
    # отклонил пересечение при одновременном создании встреч.
    raise unless e.cause.is_a?(PG::ExclusionViolation)

    @meeting.errors.add(:base, "Кто-то из участников только что был занят на это время. Проверьте расписание и попробуйте снова.")
    render_new_error
  end

  def destroy
    @meeting = Meeting.find(params[:id])
    @meeting.destroy
    redirect_to meetings_path, notice: "Встреча удалена."
  end

  private

  def render_new_error
    @employees = Employee.alphabetical
    flash.now[:alert] = "Не удалось создать встречу."
    render :new, status: :unprocessable_entity
  end

  def meeting_params
    params.require(:meeting).permit(:title, employee_ids: [])
  end

  # Значения по умолчанию для формы: сегодня, 00:00–00:00
  def set_time_defaults
    @on_date = Date.current
    @start_hour = 0
    @start_min = 0
    @end_hour = 0
    @end_min = 0
  end

  def read_time_params
    p = params[:meeting] || {}
    @on_date = parse_date(p[:on_date])
    @start_hour = p[:start_hour].to_i
    @start_min = p[:start_min].to_i
    @end_hour = p[:end_hour].to_i
    @end_min = p[:end_min].to_i
  end

  def compose_time(hour, min)
    Time.zone.local(@on_date.year, @on_date.month, @on_date.day, hour, min)
  end

  def parse_date(value)
    Date.parse(value.to_s)
  rescue ArgumentError, TypeError
    Date.current
  end
end
