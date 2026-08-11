# frozen_string_literal: true

class Review < ApplicationRecord
  after_save :recalculate_receiver_rating
  after_destroy :recalculate_receiver_rating
  after_create_commit :notify_receiver

  belongs_to :submission
  belongs_to :author, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :rating, presence: true, inclusion: { in: 1..5, message: "must be between 1 and 5" }
  validates :comment, presence: true, length: { minimum: 10, message: "must be at least 10 characters long" }
  validates :submission_id, uniqueness: { scope: :author_id, message: "has already been reviewed by you" }

  validate :submission_must_be_completed
  validate :author_and_receiver_must_be_participants

  private

  def notify_receiver
    author_name = if author.profileable_type == "StudentProfile"
      "#{author.profileable.first_name} #{author.profileable.last_name}"
    elsif author.profileable_type == "CompanyProfile"
      author.profileable.name
    else
      "A user"
    end

    Notification.trigger(
      recipient: receiver,
      action: "review_received",
      message: "#{author_name} left a #{rating}.0 ⭐ review for '#{submission.offer.title}'.",
      notifiable: submission
    )
  end

  def recalculate_receiver_rating
    profile = receiver.profileable
    profile.recalculate_average_rating! if profile.respond_to?(:recalculate_average_rating!)
  end

  def submission_must_be_completed
    if submission && submission.status != "completed"
      errors.add(:submission, "must be marked as completed before leaving a review")
    end
  end

  def author_and_receiver_must_be_participants
    return unless submission

    student_user = submission.student_profile.user
    company_user = submission.offer.company_profile.user

    allowed_participants = [ student_user, company_user ]

    unless allowed_participants.include?(author)
      errors.add(:author, "must be either the student or the employer for this internship")
    end

    unless allowed_participants.include?(receiver)
      errors.add(:receiver, "must be either the student or the employer for this internship")
    end

    if author == receiver
      errors.add(:receiver, "cannot review yourself")
    end
  end
end
