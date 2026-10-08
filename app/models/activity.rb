# frozen_string_literal: true

require "gpx"

# Activity represents an activity and its trackpoints. Trackpoints represent a
# coordinates in time with heart rate information.
class Activity < ApplicationRecord
  belongs_to :user
  enum :kind, { sup_dw: 0, sup_fwpu: 1, dockstart: 2, wingfoil: 3 }

  has_one_attached :gpx_file # , strict_loading: true
  validates :gpx_file, attached: true, content_type: "application/gpx+xml"
  after_create_commit :analyze_gpx_file_later
  after_update_commit :reanalyze_gpx_file_later, if: :saved_change_to_lift_speed_kmh?

  broadcasts_refreshes
  # For the dashboard, and other list pages
  broadcasts_refreshes_to ->(activity) { [ activity.user, :activities ] }

  has_one :analysis, dependent: :delete

  scope :with_analysis, -> { includes(:analysis) }
  # A nil kind leaves the relation unfiltered
  scope :of_kind, ->(kind) { where(kind:) if kind }

  # Set by the ActivityAnalyzerJob, stays nil if analysis fails
  def started_at = super || created_at

  # Downwinds are judged by their pace over distance
  def paced? = sup_dw?

  def analyzed?
    !!analysis&.persisted?
  end

  def analyze_gpx_file_later
    # Call #analyze_gpx_file! asynchronously
    ActivityAnalyzerJob.perform_later(self)
  end
  alias_method :reanalyze_gpx_file_later, :analyze_gpx_file_later

  def analyze_gpx_file!
    gpx_file.analyze unless gpx_file.analyzed?

    foil = gpx_file.open { |file| FoilActivityAnalyzer.new(file, lift_speed_kmh) }

    transaction do
      analysis&.destroy!
      create_analysis! foil.metadata
      update! gpx_file.metadata.slice(:title, :started_at)
    end
  end
end
