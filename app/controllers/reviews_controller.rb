# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_submission
  before_action :ensure_participant!
  before_action :ensure_completed!
  before_action :ensure_not_already_reviewed!, only: [:new, :create]

  # GET /submissions/:submission_id/reviews/new
  def new
    @review = @submission.reviews.build
  end

  # POST /submissions/:submission_id/reviews
  def create
    @review = @submission.reviews.build(review_params)
    @review.author = current_user
    @review.receiver = determine_receiver

    if @review.save
      redirect_to dashboard_path, notice: "Thank you! Your review has been submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_submission
    student_sub_ids = Submission.joins(student_profile: :user)
                                .where(users: { id: current_user.id })
                                .select(:id)
    company_sub_ids = Submission.joins(offer: { company_profile: :user })
                                .where(users: { id: current_user.id })
                                .select(:id)
    @submission = Submission.where(id: student_sub_ids)
                            .or(Submission.where(id: company_sub_ids))
                            .find(params[:submission_id])
  end

  def ensure_participant!
    student_user = @submission.student_profile.user
    company_user = @submission.offer.company_profile.user

    unless [student_user, company_user].include?(current_user)
      redirect_to dashboard_path, alert: "You are not authorized to review this internship."
    end
  end

  def ensure_completed!
    unless @submission.status == "completed"
      redirect_to dashboard_path, alert: "This internship has not been marked as completed yet."
    end
  end

  def ensure_not_already_reviewed!
    if @submission.reviews.exists?(author: current_user)
      redirect_to dashboard_path, alert: "You have already submitted a review for this internship."
    end
  end

  def determine_receiver
    student_user = @submission.student_profile.user
    company_user = @submission.offer.company_profile.user

    current_user == student_user ? company_user : student_user
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
