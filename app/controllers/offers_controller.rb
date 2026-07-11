class OffersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :ensure_company!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_offer, only: [:show, :edit, :update, :destroy]
  before_action :ensure_offer_owner!, only: [:edit, :update, :destroy]

  # GET /offers
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

    @offers = @offers.order(created_at: :desc)
  end

  # GET /offers/:id
  def show
    @company = @offer.company_profile
    @mission = @offer.mission

    if current_user && current_user.profileable_type == "StudentProfile"
      @submission = current_user.profileable.submissions.find_by(offer: @offer)
    end
  end

  # GET /offers/new
  def new
    @offer = current_user.profileable.offers.build
    @offer.build_mission
  end

  # POST /offers
  # GET /offers/:id/edit
  def edit
  end

  # PATCH /offers/:id
  def update
    if @offer.update(offer_params)
      redirect_to dashboard_path, notice: "Offer was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /offers/:id
  def destroy
    if @offer.status == "draft"
      @offer.destroy
      redirect_to dashboard_path, notice: "Draft offer was permanently deleted."
    else
      @offer.update!(status: "archived")
      redirect_to dashboard_path, notice: "Offer was archived and is no longer visible to students."
    end
  end

  def create
    @offer = current_user.profileable.offers.build(offer_params)
    
    # Track when they post their first offer for the grace period check
    company = current_user.profileable
    if company.first_offer_posted_at.nil?
      company.update!(first_offer_posted_at: Time.current)
    end

    if @offer.save
      redirect_to dashboard_path, notice: "Internship offer was successfully posted!"
    else
      # If they didn't fill out the mission fields but specified some, rebuild it to show errors
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
    unless current_user.profileable_type == "CompanyProfile"
      redirect_to dashboard_path, alert: "Only registered employers can post internship offers."
    end
  end

  def set_offer
    @offer = Offer.find(params[:id])
  end

  def ensure_offer_owner!
    unless @offer.company_profile == current_user.profileable
      redirect_to dashboard_path, alert: "You can only manage your own offers."
    end
  end
end
