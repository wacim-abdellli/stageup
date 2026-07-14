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

    # Check magic bytes if we can access the uploaded file directly before saving
    attached_change = cv.attachment.instance_variable_get(:@change) if cv.respond_to?(:attachment) && cv.attachment
    attached_change ||= cv.instance_variable_get(:@change) if cv.instance_variable_get(:@change)
    
    if attached_change.respond_to?(:attachable) && attached_change.attachable
      attachable = attached_change.attachable
      io = nil
      if attachable.respond_to?(:open)
        begin
          io = attachable.open
        rescue
          io = attachable if attachable.respond_to?(:read)
        end
      elsif attachable.respond_to?(:read)
        io = attachable
      elsif attachable.respond_to?(:tempfile)
        io = attachable.tempfile
      elsif attachable.respond_to?(:io)
        io = attachable.io
      end

      if io
        begin
          io.rewind if io.respond_to?(:rewind)
          bytes = io.read(4)
          io.rewind if io.respond_to?(:rewind)
          unless bytes == "%PDF"
            errors.add(:cv, "file is corrupted or not a valid PDF document")
          end
          return
        rescue => e
          Rails.logger.warn("[StudentProfile] Failed to read attachable: #{e.message}")
        end
      end
    end

    # Fallback/already saved
    begin
      cv.open do |file|
        unless file.read(4) == "%PDF"
          errors.add(:cv, "file is corrupted or not a valid PDF document")
        end
      end
    rescue ActiveStorage::FileNotFoundError, Errno::ENOENT => e
      # File not yet accessible during initial attachment; skip magic-byte check
      Rails.logger.warn("[StudentProfile] CV magic-byte check skipped (fallback): #{e.message}")
    end
  end
end
