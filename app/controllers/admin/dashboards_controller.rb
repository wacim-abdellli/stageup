module Admin
  class DashboardsController < AdminController
    def index
      @pending_coordinators = UniversityProfile.where(approved: false).includes(:university, :user)
      @unverified_companies = CompanyProfile.where(verified: false).includes(:user)
    end
  end
end
