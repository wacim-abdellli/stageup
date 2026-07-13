# frozen_string_literal: true

class StudentProfile < ApplicationRecord
  belongs_to :university, optional: true
  has_one :user, as: :profileable, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :commitment_events, as: :profileable, dependent: :destroy
  has_and_belongs_to_many :skills
  has_one_attached :cv

  include Rateable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :graduation_year, numericality: { only_integer: true, greater_than_or_equal_to: 2020 }, allow_nil: true
  validate :validate_cv_format

  def recalculate_commitment_score!
    with_lock do
      base = 100.0
      delta = commitment_events.sum(:score_delta)
      new_score = (base + delta).clamp(0.0, 100.0)
      update!(commitment_score: new_score)
    end
  end

  private

  def validate_cv_format
    return unless cv.attached?
    # Check file size first (fast check before anything else)
    if cv.byte_size > 5.megabytes
      errors.add(:cv, "size must be less than 5MB")
      return
    end
    # Check MIME type
    unless cv.content_type.in?(%w[application/pdf])
      errors.add(:cv, "must be a PDF document")
      return
    end
    # Check PDF magic bytes (only runs if MIME passed)
    begin
      cv.open do |file|
        unless file.read(4) == "%PDF"
          errors.add(:cv, "file is corrupted or not a valid PDF document")
        end
      end
    rescue ActiveStorage::FileNotFoundError, Errno::ENOENT => e
      Rails.logger.warn("[StudentProfile] CV magic-byte check skipped: #{e.message}")
      errors.add(:cv, "could not be verified — please try uploading again")
    end
  end
end
