# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Block legacy browsers but show a message instead of a blank page
  allow_browser versions: :modern, block: -> {
    render plain: "Your browser is not supported. Please upgrade to a modern browser (Chrome, Firefox, Safari, Edge).",
           status: :not_acceptable
  }
  # Default: all controllers require authentication.
  # Public controllers (HomeController, OffersController public actions) must use:
  #   skip_before_action :authenticate_user!, only: [...]
  before_action :authenticate_user!
  before_action :ensure_valid_profile!, if: :user_signed_in?
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, alert: "The requested resource was not found."
  end
  rescue_from ActionController::ParameterMissing do |e|
    redirect_to root_path, alert: "Missing required parameter: #{e.param}"
  end

  private

  def ensure_valid_profile!
    if current_user.profileable.nil?
      sign_out current_user
      redirect_to root_path, alert: "Your account profile is missing. Please contact support."
    end
  end
end
