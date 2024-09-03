require "gpx"

class GPXAnalyzer < ActiveStorage::Analyzer
  def self.accept?(blob)
    blob.content_type == "application/gpx+xml"
  end

  def metadata
    {
      title: track&.name,
      started_at: track&.points&.first&.time,
      ended_at: track&.points&.last&.time
    }
  end

  private

  def gpx
    @gpx ||= download_blob_to_tempfile { |file| GPX::GPXFile.new(gpx_file: file) }
  end

  def track
    # I do not care about multi sports, only a single track is expected.
    gpx.tracks[0]
  end
end
