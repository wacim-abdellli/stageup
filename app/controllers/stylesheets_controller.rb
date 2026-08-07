class StylesheetsController < ApplicationController
  skip_forgery_protection
  skip_before_action :authenticate_user!, raise: false

  def show
    css = stylesheet_source
    unless css
      head :not_found
      return
    end

    expires_in 1.year, public: true
    response.headers["Content-Type"] = "text/css; charset=utf-8"
    render plain: css
  end

  private

  def stylesheet_source
    assets_dir = Rails.public_path.join("assets")
    digested = assets_dir.glob("application-*.css").max_by(&:mtime)

    candidates = [
      assets_dir.join("application.css"),
      digested,
      Rails.root.join("app/assets/stylesheets/application.css")
    ].compact

    file = candidates.find(&:file?)
    return unless file

    css = file.read
    polish = Rails.public_path.join("certificate-polish.css")
    css = "#{css}\n#{polish.read}" unless polish.file? && css.include?("certificate-polish")
    css
  end
end
