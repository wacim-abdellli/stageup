class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to dashboard_path
    else
      @active_offers = Offer.where(status: "active").order(created_at: :desc).limit(3)
      render :index
    end
  end
end
