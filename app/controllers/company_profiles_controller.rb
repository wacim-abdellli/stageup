class CompanyProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company_profile

  def show
    @active_offers = @company_profile.offers.where(status: "active").order(created_at: :desc)
    @reviews = Review.where(target_type: "CompanyProfile", target_id: @company_profile.id).includes(:author)
    @avg_rating = Review.where(target_type: "CompanyProfile", target_id: @company_profile.id).average(:rating)&.round(1)
  end

  private

  def set_company_profile
    @company_profile = CompanyProfile.find(params[:id])
  end
end
