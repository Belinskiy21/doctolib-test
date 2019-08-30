class EventService

  def initialize(kind:, starts_at:, ends_at:, weekly_recurring:)
    @kind = kind
    @starts_at = starts_at
    @ends_at = ends_at
    @weekly_recurring = weekly_recurring
  end

  def create_events
    ActiveRecord::Base.transaction do
      unless @weekly_recurring.present?
        one_day
      else
        recurring
      end
    end
    revert_events
    return self
  end

  private

  def one_day
    if !@starts_at.to_date.sunday?
      (@starts_at.to_i...@ends_at.to_i).step(30.minutes).each do |time|
      event = Event.new(kind: @kind, starts_at: Time.at(time).utc, ends_at: Time.at(time).utc + 30.minutes, weekly_recurring: @weekly_recurring.present?)
      event.save!
      end
    end
  end

  def recurring
    8.times do
      one_day
      @starts_at += 1.day
      @ends_at += 1.day
    end
  end

  def revert_events
    grouped_by_kind =  Event.all.group_by { |event| event.kind }
    if @kind == 'appointment'
      remove_opening(grouped_by_kind)
    elsif @kind == 'opening'
      remove_appointment(grouped_by_kind)
    end
  end

  def remove_opening(grouped_by_kind)
    starts_at_values = []
    grouped_by_kind['appointment'].try(:each) do |e|
      starts_at_values << e.starts_at
    end
    starts_at_values.each do |time|
      opening_event = Event.where("starts_at = ? AND kind = ?", time, 'opening')
      opening_event.first.try(:destroy)
    end
  end

  def remove_appointment(grouped_by_kind)
    starts_at_values = []
    grouped_by_kind['opening'].try(:each) do |e|
      starts_at_values << e.starts_at
    end
    starts_at_values.each do |time|
      opening_event = Event.where("starts_at = ? AND kind = ?", time, 'appointment')
      opening_event.first.try(:destroy)
    end
  end

end
