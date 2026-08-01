# frozen_string_literal: true

class OffersController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :ensure_company!, only: [ :new, :create, :edit, :update, :destroy, :publish ]
  before_action :set_public_offer, only: [ :show ]
  before_action :set_company_offer, only: [ :edit, :update, :destroy, :publish ]
  before_action :require_auth_for_show!, only: [ :show ]

  def index
    per_page = 20
    page = [ (params[:page] || 1).to_i, 1 ].max
    @offers = Offer.where(status: "active")
    if params[:query].present?
      q_val = "%#{params[:query]}%"
      @offers = @offers.joins(:company_profile)
                       .where("offers.title ILIKE :q OR offers.description ILIKE :q OR company_profiles.name ILIKE :q", q: q_val)
    end
    @offers = @offers.where(stage_type: params[:stage_type]) if params[:stage_type].present?
    @offers = @offers.where(work_mode: params[:work_mode]) if params[:work_mode].present?
    @total_count = @offers.count
    @total_pages = (@total_count.to_f / per_page).ceil
    @current_page = page
    @offers = @offers.includes(:skills, :mission, company_profile: :user).order(created_at: :desc).limit(per_page).offset((page - 1) * per_page)
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
    @offer.with_lock do
      if @offer.submissions.none?
        @offer.destroy
        flash[:notice] = "Offer was permanently deleted."
      else
        @offer.update!(status: "archived")
        flash[:alert] = "Offer has applications and cannot be deleted. It has been archived instead."
      end
    end
    redirect_to dashboard_path
  end

  def create
    @offer = current_user.profileable.offers.build(offer_params)
    @offer.status = "draft"

    saved = false
    ActiveRecord::Base.transaction do
      if @offer.save
        saved = true
        current_user.profileable.with_lock do
          if current_user.profileable.first_offer_posted_at.nil?
            current_user.profileable.update!(first_offer_posted_at: Time.current)
          end
        end
      end
    end

    if saved
      redirect_to dashboard_path, notice: "Internship offer draft saved! Publish it when ready."
    else
      @offer.build_mission if @offer.mission.nil?
      render :new, status: :unprocessable_entity
    end
  end

  def publish
    unless @offer.status == "draft"
      redirect_to dashboard_path, alert: "Only draft offers can be published."
      return
    end
    @offer.update!(status: "active")
    redirect_to dashboard_path, notice: "Internship offer is now live!"
  end

  private

  def offer_params
    params.require(:offer).permit(
      :title, :description, :stage_type, :spots, :location, :work_mode,
      mission_attributes: [ :id, :title, :instructions, :estimated_duration_minutes ]
    )
  end

  def ensure_company!
    unless current_user.profileable_type == "CompanyProfile"
      redirect_to dashboard_path, alert: "Only verified recruiters can manage internship offers."
      return
    end

    unless current_user.profileable.verified?
      redirect_to dashboard_path, alert: "Your account is pending verification by StageUp administrators. You cannot post internship offers yet."
    end
  end

  def set_public_offer
    @offer = Offer.includes(:skills).find(params[:id])
  end

  def set_company_offer
    @offer = current_user.profileable.offers.includes(:skills).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You can only manage your own offers."
  end

  def require_auth_for_show!
    return if user_signed_in?

    redirect_to new_user_session_path, alert: "Please sign in to view full offer details."
  end
end
