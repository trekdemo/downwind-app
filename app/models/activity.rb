# frozen_string_literal: true

require "gpx"

# Activity represents an activity and its trackpoints. Trackpoints represent a
# coordinates in time with heart rate information.
class Activity < ApplicationRecord
  belongs_to :user

  has_one_attached :gpx_file
  enum :kind, { sup_dw: 0, sup_fwpu: 1, dockstart: 2, wingfoil: 3 }

  def self.create_from_gpx(gpx_file, lift_speed, user)
    gpx = GPX::GPXFile.new(gpx_file:)
    track = gpx.tracks[0]
    started_at = track&.points&.first&.time || Time.current

    create(title: track.name, lift_speed_kmh: lift_speed, gpx_file:, started_at:, user:)
  end

  def analysis
    return unless gpx_file.attached?

    @analysis ||= gpx_file.open { |file| FoilActivityAnalyzer.new(file, lift_speed_kmh) }
  rescue ActiveStorage::FileNotFoundError
    nil
  end
end
