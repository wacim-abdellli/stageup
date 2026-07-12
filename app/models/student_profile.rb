class StudentProfile < ApplicationRecord
  belongs_to :university, optional: true
  has_one :user, as: :profileable, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :commitment_events, as: :profileable, dependent: :destroy
  has_and_belongs_to_many :skills
  has_one_attached :cv

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :graduation_year, numericality: { only_integer: true, greater_than_or_equal_to: 2020 }, allow_nil: true
  validate :validate_cv_format

  def recalculate_commitment_score!
    base = 100.0
    delta = commitment_events.sum(:score_delta)
    new_score = (base + delta).clamp(0.0, 100.0)
    update!(commitment_score: new_score)
  end

  def average_rating
    return nil unless user
    reviews = Review.where(receiver: user)
    reviews.any? ? (reviews.average(:rating).to_f).round(1) : nil
  end

  def reviews_received_count
    return 0 unless user
    Review.where(receiver: user).count
  end

  private

  def validate_cv_format
    if cv.attached?
      unless cv.content_type.in?(%w[application/pdf])
        errors.add(:cv, "must be a PDF document")
      end

      if errors[:cv].none? && cv.byte_size > 0
        begin
          cv.open do |file|
            unless file.read(4) == "%PDF"
              errors.add(:cv, "file is corrupted or not a valid PDF document")
            end
          end
        rescue ActiveStorage::FileNotFoundError, Errno::ENOENT
          # File not yet accessible during initial attachment; skip magic-byte check
        end
      end

      if cv.byte_size > 5.megabytes
        errors.add(:cv, "size must be less than 5MB")
      end
    end
  end
end
