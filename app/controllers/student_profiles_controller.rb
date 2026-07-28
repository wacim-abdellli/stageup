class StudentProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student_profile

  def show
    @commitment_events = @student_profile.commitment_events.order(created_at: :desc).limit(10)
    @completed_submissions = @student_profile.submissions.where(status: %w[completed accepted]).includes(:offer)

    user = @student_profile.user
    if user
      @reviews = Review.where(receiver_id: user.id).includes(:author)
      @avg_rating = Review.where(receiver_id: user.id).average(:rating)&.round(1)
    else
      @reviews = Review.none
      @avg_rating = nil
    end
  end

  private

  def set_student_profile
    @student_profile = StudentProfile.find(params[:id])
  end
end
