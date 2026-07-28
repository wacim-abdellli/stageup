# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :reputation_events ]

  def index
    @active_offers = Offer.where(status: "active").includes(:company_profile).order(created_at: :desc).limit(3)
    @recent_events = CommitmentEvent.includes(:profileable).order(created_at: :desc).limit(3)
    render :index
  end

  def reputation_events
    events = CommitmentEvent.where(profileable_type: "CompanyProfile")
                            .order(created_at: :desc)
                            .limit(20)
                            .includes(:profileable)
    render json: events.map { |event|
      {
        entity_name: "Verified Employer",
        description: event.event_type.humanize,
        score_delta: event.score_delta,
        event_type: event.event_type,
        created_at: event.created_at
      }
    }
  end
end
