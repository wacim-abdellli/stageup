# frozen_string_literal: true

class StudentProfile < ApplicationRecord
  belongs_to :university, optional: true
  has_one :user, as: :profileable, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :active_submissions, -> { where(status: %w[accepted completed]) }, class_name: "Submission"
  has_many :commitment_events, as: :profileable, dependent: :destroy
  has_and_belongs_to_many :skills
  has_one_attached :cv

  include Rateable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :graduation_year, numericality: { only_integer: true, greater_than_or_equal_to: 2020 }, allow_nil: true
  validate :validate_cv_format

  def full_name
    "#{first_name} #{last_name}".strip
  end

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

    if cv.byte_size > 5.megabytes
      errors.add(:cv, "size must be less than 5MB")
      return
    end

    unless cv.content_type == "application/pdf"
      errors.add(:cv, "must be a PDF document")
      return
    end

    begin
      cv.blob.open do |file|
        unless file.read(4) == "%PDF"
          errors.add(:cv, "file is corrupted or not a valid PDF document")
        end
      end
    rescue ActiveStorage::FileNotFoundError, Errno::ENOENT
      Rails.logger.warn("[StudentProfile] CV magic-byte check skipped: file not yet accessible")
    end
  end
end
