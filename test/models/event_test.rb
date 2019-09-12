require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal '2014/08/10', availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["09:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal '2014/08/16', availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "when create event weekly_recurring false" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: false

    assert_equal 6, Event.all.size
  end

  test "when create event weekly_recurring true" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true

    assert_equal 312, Event.all.size
  end

  test "not create event in sunday" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2019-09-01 09:30"), ends_at: DateTime.parse("2019-09-01 12:30"), weekly_recurring: false

    assert_equal 0, Event.all.size
  end

  test "create event with 30 minutes duration" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: false

    assert_equal Event.first.ends_at.to_i - Event.first.starts_at.to_i, 30.minutes.to_i
  end

  test "not create event with invalid atrributes" do
    Event.create kind: '', starts_at: nil, ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: false

    assert_equal 0, Event.all.size
    assert 'You must provide required fields: kind, starts_at, ends_at.'
  end

  test "when create appointment event with same time as opening, opening should be replaced to appointment" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 11:00"), weekly_recurring: false
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 10:00"), weekly_recurring: false

    assert_equal 2, Event.where(kind: 'opening').size
    assert_equal 1, Event.where(kind: 'appointment').size
  end

  test "when create opening event with same time as appointment, appointment should be replaced to opening" do
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 11:00"), weekly_recurring: false
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 10:00"), weekly_recurring: false

    assert_equal 2, Event.where(kind: 'appointment').size
    assert_equal 1, Event.where(kind: 'opening').size
  end
end
