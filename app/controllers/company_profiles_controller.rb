class CompanyProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company_profile

  def show
    @active_offers = @company_profile.offers.where(status: "active").order(created_at: :desc)

    user = @company_profile.user
    if user
      @reviews = Review.where(receiver_id: user.id).includes(:author)
      @avg_rating = Review.where(receiver_id: user.id).average(:rating)&.round(1)
    else
      @reviews = Review.none
      @avg_rating = nil
    end
  end

  private

  def set_company_profile
    @company_profile = CompanyProfile.find(params[:id])
  end
end
