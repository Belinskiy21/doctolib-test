class Event < ApplicationRecord
  validates_presence_of :kind, :starts_at, :ends_at, message: 'You must provide required fields: kind, starts_at, ends_at.'

  def self.availabilities(date)
    result = []
    end_date = date + 6.days
    grouped_by_date =  Event.where(kind: "opening")
    .where(starts_at: date.beginning_of_day..end_date.end_of_day)
    .group_by { |event| event.starts_at.to_date }
    7.times do
      slots = []
      grouped_by_date[date].try(:each) do |event|
        slots << event.starts_at.strftime('%H:%M')
      end
      result << { date: date.strftime('%Y/%m/%d'), slots: slots }
      date += 1.day
    end
    result
  end

  def self.create(attributes)
    if self.validate_attributes?(attributes)
      EventService.new(
        kind: attributes[:kind],
        starts_at: attributes[:starts_at],
        ends_at: attributes[:ends_at],
        weekly_recurring: attributes[:weekly_recurring]
      ).create_events
    else
      'You must provide required fields: kind, starts_at, ends_at.'
    end
  end

  private

  def self.validate_attributes?(attributes)
    [attributes[:kind].present?,
    attributes[:starts_at].present?,
    attributes[:ends_at].present?]
    .all?
  end

end
