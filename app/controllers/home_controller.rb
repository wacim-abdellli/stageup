# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if user_signed_in?
      redirect_to dashboard_path
    else
      @active_offers = Offer.where(status: "active").order(created_at: :desc).limit(3)
      render :index
    end
  end

  def reputation_events
    events = CommitmentEvent.where(profileable_type: "CompanyProfile")
                            .order(created_at: :desc)
                            .limit(20)
                            .includes(:profileable)
    render json: events.map { |event|
      {
        entity_name: event.profileable&.name || "Anonymous",
        event_type: event.event_type,
        created_at: event.created_at
      }
    }
  end
end
