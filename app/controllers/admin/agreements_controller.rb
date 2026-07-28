module Admin
  class AgreementsController < AdminController
    def index
      @agreements = InternshipAgreement.includes(submission: [:offer, student_profile: :user])
                                       .order(created_at: :desc)

      if params[:status].present?
        @agreements = @agreements.where(status: params[:status])
      end

      @agreements = @agreements.limit(100)
    end

    def show
      @agreement = InternshipAgreement.includes(submission: [:offer, student_profile: :user]).find(params[:id])
    end
  end
end
