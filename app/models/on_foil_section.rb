# frozen_string_literal: true

# A stretch of an activity spent continuously on foil, from lift-off to
# touch-down. Distances are in meters and speeds in m/s, like on Analysis.
OnFoilSection = Data.define(:started_at, :ended_at, :distance, :speed_avg, :speed_max, :hr_avg, :hr_max, :position) do
  def duration = ended_at - started_at

  # Stores sections in a JSON column as a list of OnFoilSections
  class self::ListType < ActiveRecord::Type::Json
    def deserialize(json) = cast(super)

    def cast(sections)
      sections.to_a.map { it.is_a?(OnFoilSection) ? it : from_json(it) }
    end

    def serialize(sections) = super(sections&.map(&:to_h))

    private

    def from_json(hash)
      hash = hash.symbolize_keys
      OnFoilSection.new(**hash, started_at: hash[:started_at].in_time_zone, ended_at: hash[:ended_at].in_time_zone)
    end
  end
end
