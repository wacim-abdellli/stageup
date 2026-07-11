class Review < ApplicationRecord
  belongs_to :submission
  belongs_to :author, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :rating, presence: true, inclusion: { in: 1..5, message: "must be between 1 and 5" }
  validates :comment, presence: true, length: { minimum: 10, message: "must be at least 10 characters long" }
  validates :submission_id, uniqueness: { scope: :author_id, message: "has already been reviewed by you" }

  validate :submission_must_be_completed
  validate :author_and_receiver_must_be_participants

  private

  def submission_must_be_completed
    if submission && submission.status != "completed"
      errors.add(:submission, "must be marked as completed before leaving a review")
    end
  end

  def author_and_receiver_must_be_participants
    return unless submission

    student_user = submission.student_profile.user
    company_user = submission.offer.company_profile.user

    allowed_participants = [student_user, company_user]

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
