class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to dashboard_path
    else
      @active_offers = Offer.where(status: "active").order(created_at: :desc).limit(3)
      render :index
    end
  end

  def reputation_events
    events = CommitmentEvent.order(created_at: :desc).limit(20).includes(:profileable)
    render json: events.map { |event|
      entity_name = if event.profileable_type == "StudentProfile" && event.profileable
        "#{event.profileable.first_name} #{event.profileable.last_name.to_s.first.upcase}."
      elsif event.profileable_type == "CompanyProfile" && event.profileable
        event.profileable.name
      else
        "Anonymous"
      end

      {
        entity_name: entity_name,
        event_type: event.event_type,
        description: event.description,
        score_delta: event.score_delta,
        created_at: event.created_at
      }
    }
  end
end
