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
  before_action :set_locale
  before_action :authenticate_user!
  before_action :ensure_valid_profile!, if: :user_signed_in?

  def default_url_options
    { locale: (I18n.locale == I18n.default_locale ? nil : I18n.locale) }
  end

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, alert: "The requested resource was not found."
  end
  rescue_from ActionController::ParameterMissing do
    redirect_to root_path, alert: "A required parameter was missing."
  end

  private

  def set_locale
    loc = params[:locale]&.to_sym
    I18n.locale = loc.in?(I18n.available_locales) ? loc : (session[:locale]&.to_sym || I18n.default_locale)
    session[:locale] = I18n.locale
  end

  def ensure_valid_profile!
    if current_user.profileable.nil?
      sign_out current_user
      redirect_to root_path, alert: "Your account profile is missing. Please contact support."
    end
  end
end
