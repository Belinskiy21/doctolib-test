class EventsController < ApplicationController

  def create
    result = EventService.new(
      kind: params[:kind],
      starts_at: params[:tarts_at],
      ends_at: params[:ends_at],
      weekly_recurring: params[:weekly_recurring]
    ).create_events
    render json: result
  end

end
