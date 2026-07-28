module Admin
  class DashboardsController < AdminController
    def index
      @stats = {
        total_users: User.count,
        students_count: StudentProfile.count,
        companies_count: CompanyProfile.count,
        coordinators_count: UniversityProfile.count,
        total_offers: Offer.count,
        active_offers: Offer.where(status: "active").count,
        total_submissions: Submission.count,
        completed_submissions: Submission.where(status: %w[accepted completed]).count,
        total_agreements: InternshipAgreement.count,
        signed_agreements: InternshipAgreement.where(status: %w[signed approved]).count
      }

      @pending_coordinators = UniversityProfile.where(approved: false)
                                             .includes(:university, :user)
                                             .order(created_at: :asc)
                                             .limit(10)

      @unverified_companies = CompanyProfile.where(verified: false)
                                           .includes(:user)
                                           .order(created_at: :asc)
                                           .limit(10)

      @recent_submissions = Submission.includes(:offer, student_profile: :user)
                                      .order(created_at: :desc)
                                      .limit(10)
    end
  end
end
