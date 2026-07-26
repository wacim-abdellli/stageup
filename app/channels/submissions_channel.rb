# frozen_string_literal: true

class SubmissionsChannel < ApplicationCable::Channel
  def subscribed
    company_profile = current_user&.profileable
    return reject unless company_profile.is_a?(CompanyProfile)

    stream_from "submissions:company_#{company_profile.id}"
  end

  def unsubscribed; end
end
