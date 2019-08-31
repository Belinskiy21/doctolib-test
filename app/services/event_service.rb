class EventService
  STEP_SIZE = 30.minutes
  OPENING = 'opening'
  APPOINTMENT = 'appointment'

  def initialize(kind:, starts_at:, ends_at:, weekly_recurring:)
    @kind = kind
    @starts_at = starts_at
    @ends_at = ends_at
    @weekly_recurring = weekly_recurring
  end

  def create_events
    ActiveRecord::Base.transaction do
      unless @weekly_recurring
        one_day
      else
        recurring
      end
    end
    delete_conflict_events
  end

  private

  def one_day
    if !@starts_at.to_date.sunday?
      (@starts_at.to_i...@ends_at.to_i).step(STEP_SIZE).each do |time|
      event = Event.new(kind: @kind, starts_at: Time.at(time).utc, ends_at: Time.at(time).utc + STEP_SIZE, weekly_recurring: @weekly_recurring)
      event.save!
      end
    end
  end

  def recurring
    1.week.size.times do
      one_day
      @starts_at += 1.day
      @ends_at += 1.day
    end
  end

  def delete_conflict_events
    grouped_by_kind =  Event.all.group_by { |event| event.kind }
    if @kind == APPOINTMENT
      remove_opening(grouped_by_kind)
    elsif @kind == OPENING
      remove_appointment(grouped_by_kind)
    end
  end

  def remove_opening(grouped_by_kind)
    starts_at_values = []
    grouped_by_kind[APPOINTMENT].try(:each) { |e| starts_at_values << e.starts_at }
    starts_at_values.each do |time|
      Event.where("starts_at = ? AND kind = ?", time, OPENING).first.try(:destroy)
    end
  end

  def remove_appointment(grouped_by_kind)
    starts_at_values = []
    grouped_by_kind[OPENING].try(:each){ |e| starts_at_values << e.starts_at }
    starts_at_values.each do |time|
      Event.where("starts_at = ? AND kind = ?", time, APPOINTMENT).first.try(:destroy)
    end
  end

end
