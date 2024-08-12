# frozen_string_literal: true

require 'fast_polylines'
require 'cgi'

module ActivityMapsHelper
  # FIXME: This method should not be used from the view because it contains the
  # Mapbox credential
  #
  # https://docs.mapbox.com/api/maps/static-images/#path
  def speed_map_url(activity, size:)
    path = activity.reduced_path(250)
    last_coords = nil
    overlays =
      path.each_slice(2).map do |coords|
        coords = (coords << last_coords).compact
        last_coords = coords[-2]
        speed_avg = coords.map(&:last).sum / coords.size
        mapbox_overlay_path(
          coords.map { _1.take(2) },
          stroke_color: ColorScale.plasma[speed_avg / (activity.speed_avg + 1)],
          stroke_width: 3
        )
      end

    format(
      'https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/'\
      '%<overlays>s/auto/%<size>s@2x'\
      '?access_token=%<token>s',
      { size:, overlays: overlays.join(','), token: ENV.fetch('MAPBOX_ACCESS_TOKEN') }
    )
  end

  def mapbox_overlay_path(path, stroke_color: '000', stroke_width: 1, stroke_opacity: 1)
    format(
      'path-%<stroke_width>s+%<stroke_color>s-%<stroke_opacity>s(%<polyline>s)',
      {
        polyline: CGI.escape(FastPolylines.encode(path)),
        stroke_color: stroke_color.sub('#', ''),
        stroke_width:,
        stroke_opacity:
      }
    )
  end
end
