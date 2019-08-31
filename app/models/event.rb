class Event < ApplicationRecord
  validates_presence_of :kind, :starts_at, :ends_at, message: 'You must provide required fields: kind, starts_at, ends_at.'

  def self.availabilities(date)
    result = []
    grouped_by_date =  Event.all.group_by { |event| event.starts_at.to_date }
    1.week.size.times do
      slots = []
      grouped_by_date[date.to_date].try(:each) do |event|
        slots << event.starts_at.strftime('%H:%M') if event.kind == "opening"
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
    attributes[:kind].present? &&
    attributes[:starts_at].present? &&
    attributes[:ends_at].present?
  end

end
