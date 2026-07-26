# frozen_string_literal: true

module BroadcastableSubmission
  extend ActiveSupport::Concern

  included do
    after_update_commit :broadcast_status_change, if: :saved_change_to_status?
  end

  private

  def broadcast_status_change
    company_id = offer.company_profile_id
    ActionCable.server.broadcast(
      "submissions:company_#{company_id}",
      {
        submission_id: id,
        new_status: status,
        student_name: "#{student_profile.first_name} #{student_profile.last_name}",
        offer_title: offer.title
      }
    )
  end
end
