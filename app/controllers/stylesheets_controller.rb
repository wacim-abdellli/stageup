class StylesheetsController < ApplicationController
  skip_forgery_protection
  skip_before_action :authenticate_user!, raise: false

  def show
    css_file = Rails.root.join("app/assets/stylesheets/application.css")

    if css_file.file?
      css = css_file.read
      expires_in 1.hour, public: true
      render body: css, content_type: "text/css; charset=utf-8"
    else
      head :not_found
    end
  end
end

