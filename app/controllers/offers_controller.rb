# frozen_string_literal: true

class OffersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :ensure_company!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_offer, only: [:show, :edit, :update, :destroy]
  before_action :ensure_offer_owner!, only: [:edit, :update, :destroy]

  def index
    @offers = Offer.where(status: "active")
    if params[:query].present?
      q_val = "%#{params[:query]}%"
      @offers = @offers.joins(:company_profile)
                       .where("offers.title ILIKE :q OR offers.description ILIKE :q OR company_profiles.name ILIKE :q", q: q_val)
    end
    if params[:stage_type].present?
      @offers = @offers.where(stage_type: params[:stage_type])
    end
    if params[:work_mode].present?
      @offers = @offers.where(work_mode: params[:work_mode])
    end
    @offers = @offers.includes(:skills).order(created_at: :desc)
  end

  def show
    if @offer.status == "draft"
      unless current_user && current_user.profileable_type == "CompanyProfile" && @offer.company_profile == current_user.profileable
        redirect_to dashboard_path, alert: "Offer not found or not yet active."
        return
      end
    end
    @company = @offer.company_profile
    @mission = @offer.mission
    if current_user && current_user.profileable_type == "StudentProfile"
      @submission = current_user.profileable.submissions.find_by(offer: @offer)
    end
    @reviews = Review.where(receiver: @company.user).order(created_at: :desc).to_a if @company.user
  end

  def new
    @offer = current_user.profileable.offers.build
    @offer.build_mission
  end

  def edit
  end

  def update
    if @offer.update(offer_params)
      redirect_to dashboard_path, notice: "Offer was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @offer.submissions.none?
      @offer.destroy
      redirect_to dashboard_path, notice: "Offer was permanently deleted."
    else
      @offer.update!(status: "archived")
      redirect_to dashboard_path, alert: "Offer has applications and cannot be deleted. It has been archived instead."
    end
  end

  def create
    @offer = current_user.profileable.offers.build(offer_params)

    current_user.profileable.with_lock do
      if current_user.profileable.first_offer_posted_at.nil?
        current_user.profileable.update!(first_offer_posted_at: Time.current)
      end
    end

    if @offer.save
      redirect_to dashboard_path, notice: "Internship offer was successfully posted!"
    else
      @offer.build_mission if @offer.mission.nil?
      render :new, status: :unprocessable_entity
    end
  end

  private

  def offer_params
    params.require(:offer).permit(
      :title, :description, :stage_type, :spots, :location, :work_mode,
      mission_attributes: [:id, :title, :instructions, :estimated_duration_minutes]
    )
  end

  def ensure_company!
    if current_user.profileable_type == "CompanyProfile" && current_user.profileable.verified?
      return
    elsif current_user.profileable_type == "CompanyProfile" && !current_user.profileable.verified?
      redirect_to dashboard_path, alert: "Your account is pending verification by StageUp administrators. You cannot post internship offers yet."
    elsif current_user.profileable_type == "StudentProfile"
      redirect_to dashboard_path, alert: "Only verified recruiters can manage internship offers."
    else
      redirect_to dashboard_path, alert: "You are not authorized to perform this action."
    end
  end

  def set_offer
    @offer = Offer.includes(:skills).find(params[:id])
  end

  def ensure_offer_owner!
    unless @offer.company_profile == current_user.profileable
      redirect_to dashboard_path, alert: "You can only manage your own offers."
    end
  end
end
