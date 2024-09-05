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

  broadcasts_refreshes

  has_one :analysis, dependent: :delete

  scope :with_analysis, -> { includes(:analysis) }

  def analyzed?
    analysis.present?
  end

  def analyze_gpx_file_later
    ActivityAnalyzerJob.perform_later(self)
  end

  def analyze_gpx_file!
    gpx_file.analyze unless gpx_file.analyzed?

    analysis.delete if analysis
    foil = gpx_file.open { |file| FoilActivityAnalyzer.new(file, lift_speed_kmh) }

    create_analysis foil.metadata
    update! gpx_file.metadata.slice(:title, :started_at)
  end
end
