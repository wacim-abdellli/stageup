module Admin
  class OffersController < AdminController
    before_action :set_offer, only: [:show, :toggle_status, :destroy]

    def index
      @offers = Offer.includes(:company_profile).order(created_at: :desc)

      if params[:query].present?
        q = "%#{params[:query].downcase}%"
        @offers = @offers.where("LOWER(title) LIKE ? OR LOWER(location) LIKE ?", q, q)
      end

      if params[:status].present?
        @offers = @offers.where(status: params[:status])
      end

      @offers = @offers.limit(100)
    end

    def show
    end

    def toggle_status
      new_status = @offer.status == "active" ? "closed" : "active"
      @offer.update(status: new_status)
      redirect_to admin_offers_path, notice: "Offer '#{@offer.title}' status updated to #{new_status}."
    end

    def destroy
      title = @offer.title
      @offer.destroy
      redirect_to admin_offers_path, notice: "Offer '#{title}' has been deleted."
    end

    private

    def set_offer
      @offer = Offer.find(params[:id])
    end
  end
end
