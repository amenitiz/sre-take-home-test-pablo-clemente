class Service < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :url, presence: true

  STATUSES = %w[operational degraded outage maintenance].freeze

  validates :status, inclusion: { in: STATUSES }

  scope :operational, -> { where(status: "operational") }
  scope :issues, -> { where.not(status: "operational") }

  def operational?
    status == "operational"
  end

  def status_color
    case status
    when "operational" then "green"
    when "degraded" then "yellow"
    when "outage" then "red"
    when "maintenance" then "blue"
    end
  end
end
