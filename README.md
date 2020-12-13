# README
The goal is to write an algorithm that checks the availabilities of an agenda depending of the events attached to it. The main method has a start date for input and is looking for the availabilities of the next 7 days.

They are two kinds of events:

opening, are the openings for a specific day and they can be recurring week by week.
appointment, times when the doctor is already booked.
Your Mission:

Pick either the Ruby technical test
Your code must pass the provided unit tests
Your code must be SQLite compatible

Coding in Ruby?

Must run with ruby 2.6.0
Must run with rails 5.2.3
Don’t add any gems
Stick to event.rb and event_test.rb files



unit tests:
class EventTest < ActiveSupport::TestCase

  test "one simple test example" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 13:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal '2014/08/10', availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal '2014/08/11', availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00", "12:30", "13:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal '2014/08/16', availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

end
