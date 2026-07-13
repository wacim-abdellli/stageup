module Admin
  class DashboardsController < AdminController
    def index
      @pending_coordinators = UniversityProfile.where(approved: false)
                                             .includes(:university, :user)
                                             .order(created_at: :asc)
                                             .limit(50)
      @unverified_companies = CompanyProfile.where(verified: false)
                                          .includes(:user)
                                          .order(created_at: :asc)
                                          .limit(50)
    end
  end
end
