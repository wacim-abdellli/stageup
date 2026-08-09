# frozen_string_literal: true

class Offer < ApplicationRecord
  belongs_to :company_profile
  has_one :mission, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_and_belongs_to_many :skills

  MAJOR_STAGE_MAP = {
    "PFE"        => %w[engineering informatique software développement cs computer science],
    "PFA"        => %w[business gestion commerce économie finance management],
    "initiation" => [],
    "free"       => []
  }.freeze

  def match_percentage_for(student)
    match_breakdown_for(student)[:total]
  end

  def match_breakdown_for(student)
    return { skill: 0.0, major: 0.0, readiness: 0.0, total: 0 } unless student

    s_score = skill_match_score(student)
    m_score = major_alignment_score(student)
    r_score = commitment_readiness_score(student)
    tot = (s_score + m_score + r_score).round.clamp(0, 100)

    { skill: s_score.round(1), major: m_score.round(1), readiness: r_score.round(1), total: tot }
  end

  accepts_nested_attributes_for :mission, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :description, presence: true
  validates :stage_type, presence: true, inclusion: { in: %w[PFE PFA initiation free] }
  validates :spots, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true
  validates :work_mode, presence: true, inclusion: { in: %w[onsite remote hybrid] }
  validates :status, presence: true, inclusion: { in: %w[draft active filled archived] }

  def draft?
    status == "draft"
  end

  def duration_months
    case stage_type
    when "PFE" then 4
    when "PFA" then 2
    when "initiation" then 1
    else 3
    end
  end

  private

  def skill_match_score(student)
    return 60.0 if skills.empty?
    return 0.0  if student.skills.empty?

    matched = (student.skills & skills).size
    (matched.to_f / skills.size) * 60.0
  end

  def major_alignment_score(student)
    return 25.0 if stage_type.in?(%w[initiation free])

    keywords = MAJOR_STAGE_MAP[stage_type] || []
    return 12.5 if keywords.empty?
    return 12.5 if student.major.blank?

    student.major.downcase.split.any? { |word| keywords.include?(word) } ? 25.0 : 0.0
  end

  def commitment_readiness_score(student)
    score = student.commitment_score.to_f
    return 15.0 if score >= 80

    (score / 80.0) * 15.0
  end
end
